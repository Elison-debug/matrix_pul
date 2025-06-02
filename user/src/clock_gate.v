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
  reg clken,clken_next;
  reg en_before,en_before_next; 
  reg start_in_next;
  assign rst_o = clken;

  always @(posedge clk_i or negedge rst) begin
    if (!rst) begin
        clken     = 1'b0;
        start_in  = 1'b0;
        en_before = 1'b0;
    end else begin
        clken     = clken_next;
        start_in  = start_in_next;
        en_before = en_before_next;
    end
  end
  // Clock gating logic
  always@(*) begin
    clken_next = clken;
    en_before_next = clken;
    if (clk_en) begin
        clken_next = 1'b1;
    end else if (clk_end) begin
        clken_next = 1'b0;
    end
    
  end

  // Start signal logic
  always@(*) begin
    start_in_next = start_in;
    if (clken && !en_before) begin
        start_in_next = 1'b1;
    end else begin
        start_in_next = 1'b0;
    end
  end

  assign clk_o = clk_i & clken_next;

endmodule
