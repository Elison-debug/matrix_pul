module controller(
    input  clk,
    input  rst,
    input  web,
    input  start_in,
    input  xload_done,

    output input_load_en,
    output ALU_en
);  
    //FSM state
    parameter IDLE        = 2'b00;
    parameter shift_input = 2'b01;
    parameter ALU         = 2'b10;
    parameter next_col    = 2'b11;
    
    //state
    reg [1:0] state;
    reg [1:0] state_next;

    //counter
    reg [1:0] count_col;
    reg [1:0] count_col_next;
    

    //enable signal
    assign ALU_en=(state == ALU) ? 1'b1 : 1'b0;
    assign input_load_en = (state == shift_input) ? 1'b1 : 1'b0;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        //reset state and counter
        count_col   <= 2'b0;
        state <= IDLE;
    end
    else begin
        //update state and counter
        state <= state_next;
        count_col <= count_col_next;
        
    end
end

//FSM for calculate
always @(*) begin
    count_col_next = count_col;
    state_next = state;
    //update state
    case (state) 
        IDLE        : begin state_next = start_in ? shift_input : IDLE; count_col_next  = 2'b0; end//if start_in = 1 start shift
        shift_input : state_next = xload_done ? ALU : shift_input;//if finish both A and X matrix input then start ALU
        ALU         : state_next = web   ? next_col : ALU;        //if count_mul = 8 start next_col
        next_col    : begin state_next = (count_col == 2'b11) ? IDLE : ALU; count_col_next = count_col + 2'b1;end //if count_col = 3 go IDLE, else back to ALU next col
        default     : state_next = IDLE;
    endcase
end

endmodule