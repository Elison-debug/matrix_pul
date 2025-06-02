`timescale 1ns / 1ns
module acc_ram#(
    parameter APB_ADDR_WIDTH = 13  //APB slaves are 8KB by default
)
(
    input            clk,
    input            rst,
    input            en_i,
    input            we_i,
    input  [11:0]    w_addr_i,
    input  [11:0]    r_addr_i,
    input  [31:0]    wdata_i,
    output [31:0]    rdata_o,
    output           ry_o
  );
  // 2048 x 8-bit SRAM, 4 banks of 8-bit each
  reg  ry_count;
  wire ry_count_next;

  wire LOW = 1'b0;
  wire [31:0] byte_rdata;

  wire [APB_ADDR_WIDTH-1:0]  addr;
  assign addr = we_i ?  r_addr_i : w_addr_i;
  assign ry_o = (ry_count == 1'b1);
  assign ry_count_next = (en_i && we_i) ? ry_count + 1'b1 : ry_count;
  always @(posedge clk or negedge rst) begin
    if(!rst) begin
        ry_count   <= 1'b0;
    end
    else begin
        ry_count  <= ry_count_next;
    end
end
  
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : ram_byte
      ST_SPHDL_2048x8m8_L sram_2k (
        .Q        ( byte_rdata[(i+1)*8-1 -: 8]),
        .RY       (                ),
        .A        ( addr[12:2]     ), // 11-bit word addr
        .CK       ( clk            ),
        .CSN      ( ~en_i          ),
        .TBYPASS  ( LOW            ),
        .WEN      ( we_i           ),
        .D        ( wdata_i[(i+1)*8-1 -: 8] )
      );
    end
  endgenerate

  assign rdata_o = byte_rdata;

endmodule
