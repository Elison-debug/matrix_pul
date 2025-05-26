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
    output [4:0] col_count,
    output [1:0] row_count
);  
    //FSM fsm_state
    parameter IDLE        = 2'b000;
    parameter load_data   = 2'b001;
    parameter calculate   = 2'b010;
    parameter next_col    = 2'b111;
    parameter next_row    = 2'b101;
    parameter tot_times   = 2'd28;
    
    //fsm_state
    reg [2:0] fsm_state;
    reg [2:0] fsm_state_next;

    //row counter
    reg [7:0] count;
    reg [7:0] count_next;

    //calculate counter
    reg  [4:0] shift_count;
    reg  [4:0] shift_count_next;
    assign shift_counter = shift_count;

    //update shift counter
    assign shift_count_next = (fsm_state == calculate) ? shift_count + 1'b1 : 5'b0;

    //flag of column calculation finished
    wire   row_finish;
    assign row_finish  = (shift_count == 5'd28);

    assign col_count = shift_count;
    assign row_count = count[1:0];
    //finish acc flag
    assign acc_finish  = (count == tot_times ) ? 1'b0 : 1'b1;

    //enable signals
    assign ALU_en  = (fsm_state == calculate) ? 1'b1 : 1'b0;
    assign load_en = (fsm_state == load_data) ? 1'b1 : 1'b0;
    assign pready  = (fsm_state == load_data||fsm_state == IDLE) ? 1'b1 : 1'b0;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        //reset fsm_state and counter
        count         <= 5'b0;
        shift_count   <= 5'b0;
        fsm_state     <= IDLE;
    end
    else begin
        //update fsm_state and counter
        count       <= count_next;
        shift_count <= shift_count_next;
        fsm_state   <= fsm_state_next;
    end
end

//FSM for calculate
always @(*) begin
    fsm_state_next = fsm_state;
    //update fsm_state
    case (fsm_state) 
        IDLE        : begin fsm_state_next = start_in   ? load_data : IDLE; end //if start_in = 1 start load_data
        load_data   : begin fsm_state_next = load_done  ? calculate : load_data; end  //load data to ALU
        calculate   : begin fsm_state_next = row_finish ? next_col  : calculate; end  //if calculation finished start load next column
        next_row    : begin fsm_state_next = acc_finish ? load_data : IDLE ; end  //if data loaded shift data to ALU
        default     : fsm_state_next = IDLE;
    endcase 
end

//counter logic
always @(*) begin
    count_next = count;
    //update row counter
    if(acc_finish)
        count_next = 5'b0;
    else begin
        count_next  = load_done ? (count + 1'b1) : count;
    end
end


endmodule