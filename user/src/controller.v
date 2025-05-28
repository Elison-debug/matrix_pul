`timescale 1ns / 1ns
module controller(
    input  clk,
    input  rst,
    input  ry_o,
    input  start_in,
    input  load_A_done,
    input  load_done,

    output pready,
    output ALU_en,
    output load_en,
    output load_A_en,
    output row_finish,
    output [4:0] row_count
);  
    //FSM fsm_state
    localparam IDLE        = 3'b000;
    localparam load_A      = 3'b100;
    localparam load_data1  = 3'b001;
    localparam load_data2  = 3'b010;
    localparam calculate   = 3'b011;
    //localparam next_col    = 3'b111;
    localparam next_row    = 3'b101;
    localparam last_row    = 3'b110;
    localparam tot_times   = 5'd28;
    
    //fsm_state
    reg [2:0] fsm_state;
    reg [2:0] fsm_state_next;

    //row counter
    reg [4:0] count;
    reg [4:0] count_next;

    //calculate counter
    reg  [4:0] shift_count;
    wire [4:0] shift_count_next;
    assign shift_counter = shift_count;

    //update shift counter
    assign shift_count_next = (fsm_state == calculate)||(fsm_state == last_row) ? shift_count + 1'b1 : 5'b0;

    //flag of column calculation finished
    assign row_finish  = (shift_count == 5'd27);

    assign row_count = count;
    //finish acc flag
    assign acc_finish  = (count == tot_times ) ? 1'b1 : 1'b0;

    //enable signals
    //assign ALU_en    = (fsm_state == calculate)||(fsm_state == next_row ) ? 1'b1 : 1'b0;
    assign ALU_en    = (fsm_state == calculate)||(fsm_state == last_row) ? 1'b1 : 1'b0;
    assign load_en   = (fsm_state != IDLE) ? 1'b1 : 1'b0;
    assign load_A_en = (fsm_state == load_A)   ? 1'b1 : 1'b0;
    assign pready    = fsm_state == IDLE || load_en || load_A_en ||ry_o; //ready to accept new data

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
        IDLE        : begin fsm_state_next = start_in    ? load_A    : IDLE; count_next = 5'b0;end //if start_in = 1 start load_data
        load_A      : begin fsm_state_next = load_A_done ? load_data1: load_A; end  //load A to ALU
        load_data1  : begin fsm_state_next = load_done   ? load_data2: load_data1; end  //load data to ALU
        load_data2  : begin fsm_state_next = load_done   ? calculate : load_data2; end  //load data to ALU
        calculate   : begin fsm_state_next = row_finish  ? next_row  : calculate ; end  //if calculation finished start load next column
        next_row    : begin fsm_state_next = acc_finish  ? last_row  : load_data2; end  //if data loaded shift data to ALU
        last_row    : begin fsm_state_next = row_finish  ? IDLE      : last_row   ;end  //if last row loaded then go to idle
        default     : fsm_state_next = IDLE;
    endcase 
end

//counter logic
always @(*) begin
    count_next = count;
    //update row counter
        
    if(load_done)begin
        count_next  = count + 1'b1;
    end
end


endmodule