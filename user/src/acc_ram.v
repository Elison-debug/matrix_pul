`timescale 1ns / 1ns
module acc_ram(
    input            clk,
    input            en_i,
    input            we_i,
    input  [12:0]    w_addr_i,
    input  [12:0]    r_addr_i,
    input  [31:0]    wdata_i,
    output [31:0]    rdata_o,
    output           ry_o
  );

  // 2048 x 8-bit SRAM, 4 banks of 8-bit each
  wire [12:0]  addr;
  wire ry_sram;
  assign addr = we_i ?  r_addr_i : w_addr_i;
  assign ry_o = ~(en_i && ~we_i && ~ry_sram); //1 ready
  wire LOW = 1'b0;
  wire [7:0] byte_rdata [0:3];
 
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : ram_byte
      ST_SPHDL_2048x8m8_L sram_2k (
        .Q        ( byte_rdata[i]  ),
        .RY       ( ry_sram        ),
        .A        ( addr[12:2]     ), // 11-bit word addr
        .CK       ( clk            ),
        .CSN      ( ~en_i          ),
        .TBYPASS  ( LOW            ),
        .WEN      ( we_i           ),
        .D        ( wdata_i[(i+1)*8-1 -: 8] )
      );
    end
  endgenerate

  assign rdata_o = {byte_rdata[3], byte_rdata[2], byte_rdata[1], byte_rdata[0]};

endmodule
