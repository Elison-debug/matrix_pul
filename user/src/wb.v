`timescale 1ns / 1ns
module wb(
    input  clk,
    input  rst,
    input  web,
    input  [19:0] sum,

    output [12:0] w_addr,
    output [31:0] dataRAM
);
    //state
    reg wb_next;
    reg wb_state;

    localparam wb_IDLE  = 1'b0;
    localparam wb_start = 1'b1;

    //ram address
    reg [12:0] ram_addr;
    reg [12:0] ram_addr_next;
    assign w_addr = ram_addr;

    //dataRAM and ram enable signal
    assign dataRAM[31:20] = 12'b0;
    assign dataRAM[19: 0] = sum;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        ram_addr  <= 12'b0;
    end
    else begin
        ram_addr  <= ram_addr_next;
    end
end

always @(*) begin
    ram_addr_next  = ram_addr;
    ram_addr_next  = web ? ram_addr : ram_addr + 12'd4 ; //if ram en then count else wait
end

endmodule
