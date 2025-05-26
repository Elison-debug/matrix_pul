module controller(
    input  clk,
    input  rst,
    input  start_in,
    input  load_done,

    output ALU_en,
    output pready,
    output load_en,
    output row_finish,
    output acc_finish, 
    output shift_counter,
    output acc_counter
);  
    //FSM state
    parameter IDLE        = 2'b000;
    parameter load_data   = 2'b001;
    parameter calculate   = 2'b010;
    parameter next_col    = 2'b111;
    parameter next_row    = 2'b101;
    parameter tot_times   = 2'd112;
    
    //state
    reg [2:0] state;
    reg [2:0] state_next;
    assign fsm_state = state;

    //counter
    reg [7:0] count;
    reg [7:0] count_next;

    reg  [3:0] shift_count;
    reg  [3:0] shift_count_next;
    assign shift_counter = shift_count;
    wire cal_finish;
    assign cal_finish  = (shift_count == 4'd8);
    assign col_counter = count[1:0];
    assign row_finish  = (col_counter == 2'b11) ? 1'b0 : 1'b1;
    assign acc_finish  = (count == tot_times ) ? 1'b0 : 1'b1;

    //enable signals
    assign ALU_en  = (fsm_state == calculate) ? 1'b1 : 1'b0;
    assign load_en = (fsm_state == load_data) ? 1'b1 : 1'b0;
    assign pready  = (fsm_state == load_data||fsm_state == IDLE) ? 1'b1 : 1'b0;
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        //reset state and counter
        count     <= 5'b0;
        state     <= IDLE;
    end
    else begin
        //update state and counter
        state   <= state_next;
        count   <= count_next;
    end
end

//FSM for calculate
always @(*) begin
    state_next = state;
    //update state
    case (state) 
        IDLE        : begin state_next = start_in   ? load_data : IDLE; end //if start_in = 1 start load_data
        load_data   : begin state_next = load_done  ? calculate : load_data; end  //load data to ALU
        calculate   : begin state_next = cal_finish ? next_col  : calculate; end  //if calculation finished start load next column
        next_col    : begin state_next = row_finish ? load_data : next_row ; end  //finished calculation or load next column 
        next_row    : begin state_next = acc_finish ? load_data : IDLE; end  //if data loaded shift data to ALU
        default     : state_next = IDLE;
    endcase 
end

//counter logic
always @(*) begin
    shift_count_next = shift_count;
    count_next = count;
    //update sub COLUMN counter
    if(acc_finish)
        count_next = 5'b0;
    else begin
        count_next  = load_done ? (count + 1'b1) : count;
    end
    //update shift counter
    if(state == calculate) begin
        shift_count_next = shift_count + 1'b1;
    end
    else begin
        shift_count_next = 2'b00;
    end
end


endmodule