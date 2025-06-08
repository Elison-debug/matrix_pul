// Description: Clock gating module
`timescale 1ns / 1ns
module clock_gate
(
    input                        clk_i    ,   // input clock
    input                        rst      ,   // reset signal
    input                        clk_en   ,   // clock enable signal
    input                        clk_end  ,   // clock down signal
    output  reg                  start_in ,   // start write sram signal
    output                       rst_o    ,
    output                       clk_o
  );
// Clock enable signal
  wire testmode;
  assign testmode = 1'b0;

  reg [3:0] clken;
  reg clken_next;
  reg start_in_next;
  assign rst_o = clken[2] && rst;

  always @(posedge clk_i or negedge rst) begin
    if (!rst) begin
        clken     <= 4'b0;
        start_in  <= 1'b0;
    end else begin
        start_in  <= start_in_next;
        clken     <= {clken[2:0],clken_next};
    end
  end
  // Clock gating logic
  always@(*) begin
    
    if (clk_en) begin
        clken_next = 1'b1;
    end else if (clk_end) begin
        clken_next = 1'b0;
    end else
        clken_next     = clken[0];
    
  end
  
  // Start signal logic
  always@(*) begin
    start_in_next = start_in;
    if (clken[2] && !clken[3]) begin
        start_in_next = 1'b1;
    end else begin
        start_in_next = 1'b0;
    end
  end

cluster_clock_gating u_clk_gate
(
    .clk_i       (clk_i       ),
    .en_i        (clken[1]    ),
    .test_en_i   (testmode    ),
    .clk_o       (clk_o       )
  );
/*
  assign clk_o = clk_i & clken_next;
*/
endmodule



