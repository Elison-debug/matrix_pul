`timescale 1ns / 1ns
module X_buffer#(
    parameter APB_ADDR_WIDTH = 13  //APB slaves are 4KB by default
)(
    input  clk,
    input  rst,
    input  ALU_en, //En shift buffer
    input  load_en,
    input  valid_input,
    input  row_finish,
    input  [31:0] X_load,    //input data
    input  [4 :0] row_count,
    output [23:0] X_reg1,  
    output [23:0] X_reg2,
    output [23:0] X_reg3,
    output load_done
);
    //counter
    reg [2:0] count;
    reg [2:0] count_next;
    assign load_done = (count == 3'd7) ? 1'b1 : 1'b0;
    // four X buffer
    reg [239:0] s_reg [3:0];
    reg [239:0] s_reg_next [3:0];

    assign X_reg1 = s_reg[row_count[1:0]+2'b01][239:216];
    assign X_reg2 = s_reg[row_count[1:0]+2'b10][239:216];
    assign X_reg3 = s_reg[row_count[1:0]+2'b11][239:216];

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
    if(load_done) begin
        count_next = 3'b0;
    end
    else if(row_count==5'd28 && row_finish) begin
        s_reg_next[row_count[1:0]] = 240'b0;
        count_next = count + 3'd7;  
    end
    else if(load_en && valid_input)begin
        s_reg_next[row_count[1:0]] = {8'b0, s_reg[row_count[1:0]][199:8], X_load, 8'b0};
        count_next = count +1'b1;  
    end 
    if(row_finish)begin
        s_reg_next[row_count[1:0]+2'b01] = {s_reg[row_count[1:0]+2'b01][215:0] , s_reg[row_count[1:0]+2'b01][239:216]};
        s_reg_next[row_count[1:0]+2'b10] = {s_reg[row_count[1:0]+2'b10][215:0] , s_reg[row_count[1:0]+2'b10][239:216]};
        s_reg_next[row_count[1:0]+2'b11] = {s_reg[row_count[1:0]+2'b11][215:0] , s_reg[row_count[1:0]+2'b11][239:216]};
    end
    else if(ALU_en) begin
        s_reg_next[row_count[1:0]+2'b01] = {s_reg[row_count[1:0]+2'b01][231:0] , s_reg[row_count[1:0]+2'b01][239:232]};
        s_reg_next[row_count[1:0]+2'b10] = {s_reg[row_count[1:0]+2'b10][231:0] , s_reg[row_count[1:0]+2'b10][239:232]};
        s_reg_next[row_count[1:0]+2'b11] = {s_reg[row_count[1:0]+2'b11][231:0] , s_reg[row_count[1:0]+2'b11][239:232]};
    end
    
end

endmodule