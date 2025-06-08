`timescale 1ns / 1ns
module X_buffer(
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
    assign load_done = count == 3'd7;
    // four X buffer
    reg [239:0] s_reg [3:0];
    reg [239:0] s_reg_next [3:0];
    reg [1:0] addr, addr_1,addr_2,addr_3;

    always @(*) begin
        addr   = row_count[1:0];
        addr_1 = row_count[1:0]+2'b01;
        addr_2 = row_count[1:0]+2'b10;
        addr_3 = row_count[1:0]+2'b11;
    end

    assign X_reg1 = s_reg[addr_1][23:0];
    assign X_reg2 = s_reg[addr_2][23:0];
    assign X_reg3 = s_reg[addr_3][23:0];

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        s_reg[0]   <= 240'b0;
        s_reg[1]   <= 240'b0;
        s_reg[2]   <= 240'b0;
        s_reg[3]   <= 240'b0;
        count      <= 3'b0;
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
        s_reg_next[addr] = 240'b0;
        count_next = count + 3'd7;  
    end
    else if(load_en && valid_input)begin
        s_reg_next[addr] = {8'b0, X_load, s_reg[addr][231:40], 8'b0};
        count_next = count +1'b1;  
    end 
    if(row_finish)begin
        s_reg_next[addr_1] = {s_reg[addr_1][23:0] , s_reg[addr_1][239:24]};
        s_reg_next[addr_2] = {s_reg[addr_2][23:0] , s_reg[addr_2][239:24]};
        s_reg_next[addr_3] = {s_reg[addr_3][23:0] , s_reg[addr_3][239:24]};
    end
    else if(ALU_en) begin
        s_reg_next[addr_1] = {s_reg[addr_1][7:0] , s_reg[addr_1][239:8]};
        s_reg_next[addr_2] = {s_reg[addr_2][7:0] , s_reg[addr_2][239:8]};
        s_reg_next[addr_3] = {s_reg[addr_3][7:0] , s_reg[addr_3][239:8]};
    end
    
end

endmodule
