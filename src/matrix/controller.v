module controller(
    input  clk,
    input  rst,
    input  start_in,
    input  load_done,
    input  cal_finish, 

    output ALU_en,
    output pready,
    output load_en,
    output acc_finish, 
    output shift_data_en,
    output [1:0] col_counter
);  
    //FSM state
    parameter IDLE        = 2'b000;
    parameter load_data   = 2'b001;
    parameter calculate   = 2'b011;
    parameter shift_data  = 2'b010;
    parameter next_col    = 2'b111;
    parameter cal_times   = 2'd112;
    
    //state
    reg [2:0] state;
    reg [2:0] state_next;
    assign fsm_state = state;

    //counter
    reg [7:0] count;
    reg [7:0] count_next;

    reg [1:0] shift_count;
    reg [1:0] shift_count_next;

    assign col_counter = count[1:0];
    assign acc_finish  = (count == cal_times) ? 1'b0 : 1'b1;
    assign count_next  = load_done ? (count + 1'b1) : count;
    assign shift_count_next = (fsm_state == shift_data) ? (shift_count + 1'b1) : shift_count;

    //enable signals
    assign shift_data_en = (fsm_state == shift_data) ? 1'b1 : 1'b0;

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
    count_next = count;
    state_next = state;
    //update state
    case (state) 
        IDLE        : begin state_next = start_in   ? load_data : IDLE; count_next = 5'b0; end //if start_in = 1 start load_data
        load_data   : begin state_next = load_done  ? calculate : load_data;   end  //load data to ALU
        calculate   : begin state_next = cal_finish ? shift_data: calculate;   end  //if calculation finished start load next row
        shift_data  : begin state_next = load_done  ? next_col  : calculate; end  //if data loaded shift data to ALU
        next_col    : begin state_next = acc_finish ? load_data : IDLE; end  //finished calculation or load next column 
        default     : state_next = IDLE;
    endcase 
end

endmodule