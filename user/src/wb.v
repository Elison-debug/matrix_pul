`timescale 1ns / 1ns
module wb(
    input  clk,
    input  rst,
    input  web,
    input  [19:0] sum,

    output [11:0] w_addr,
    output [31:0] dataRAM
);
    //state
    reg wb_next;
    reg wb_state;

    //ram address
    reg  [11:0] ram_addr;
    wire [11:0] ram_addr_next;
    assign w_addr = ram_addr;
    assign ram_addr_next  = web ? ram_addr + 12'd4 : ram_addr ; //if ram en then count else wait
    //dataRAM and ram enable signal
    assign dataRAM = {12'b0,sum};

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        ram_addr  <= 12'b0;
    end
    else begin
        ram_addr  <= ram_addr_next;
    end
end




endmodule
