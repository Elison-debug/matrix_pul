module X_buffer#(
    parameter APB_ADDR_WIDTH = 13  //APB slaves are 4KB by default
)(
    input  clk,
    input  rst,
    input  ALU_en, //En shift buffer
    input  load_en,
    input  valid_input,
    input  [32:0] X_load,    //input data
    input  [1 :0] row_counter,
    output [23:0] X_reg1,  
    output [23:0] X_reg2,
    output [23:0] X_reg3,
    output load_done
);
    //counter
    reg [3:0] count;
    reg [3:0] count_next;
    assign load_done = (count == 4'd27) ? 1'b1 : 1'b0;
    // four X buffer
    reg [243:0] s_reg [3:0];
    reg [243:0] s_reg_next [3:0];

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        s_reg[0]   <= 72'b0;
        s_reg[1]   <= 72'b0;
        s_reg[2]   <= 72'b0;
        s_reg[3]   <= 72'b0;
        count       <= 3'b0;
    end
    else begin
        //update counter
        count      <= count_next;
        s_reg[0]   <= s_reg_next[0];
        s_reg[1]   <= s_reg_next[1];
        s_reg[2]   <= s_reg_next[2];
        s_reg[3]   <= s_reg_next[3];
    end
end

//buffer load
always @(*) begin
    count_next       = count;
    s_reg_next[0]    = s_reg[0];
    s_reg_next[1]    = s_reg[1];
    s_reg_next[2]    = s_reg[2];
    s_reg_next[3]    = s_reg[3];
    if(load_en && valid_input)begin
        case(row_counter)
            2'b00 : begin 
                    s_reg_next[1] = {8'b0, s_reg[0][191:16], X_load, 8'b0}; 
                 end 
            2'b01 : begin 
                    s_reg_next[2] = {8'b0, s_reg[0][191:16], X_load, 8'b0}; 
                 end
            2'b10 : begin 
                    s_reg_next[3] = {8'b0, s_reg[0][191:16], X_load, 8'b0}; 
                 end
            2'b11 : begin 
                    s_reg_next[0] = {8'b0, s_reg[0][191:16], X_load, 8'b0}; 
                 end
            default : begin
                    count_next = count;  
            end
        endcase
        count_next = count +1'b1;  
    end 
    else if(ALU_en) begin
        s_reg_next[row_counter+2'b00] = {s_reg[row_counter+2'b00][215:0] , s_reg[row_counter+2'b00][243:216]};
        s_reg_next[row_counter+2'b01] = {s_reg[row_counter+2'b01][215:0] , s_reg[row_counter+2'b01][243:216]};
        s_reg_next[row_counter+2'b11] = {s_reg[row_counter+2'b11][215:0] , s_reg[row_counter+2'b11][243:216]};
    end
end

endmodule