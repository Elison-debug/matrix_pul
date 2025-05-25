// Description: Clock gating module
module clock_gate
#(
    parameter APB_ADDR_WIDTH = 12  //APB slaves are 4KB by default
)
(
    input                        clk_i    ,   // input clock
    input                        rst      ,   // reset signal
    input                        clk_en   ,   // clock enable signal
    input                        clk_end  ,   // clock down signal
    output  reg                  start_in ,   // start write sram signal
    output                       clk_o
  );
// Clock enable signal
  reg clken,clken_next,en_before; 
  reg start_in_next;

  always @(posedge clk_i or negedge rst) begin
    if (!rst) begin
        clken     = 1'b0;
        start_in  = 1'b0;
        en_before = 1'b0;
    end else begin
        clken     = clken_next;
        start_in  = start_in_next;
        en_before = clken;
    end
  end
  // Clock gating logic
  always@(*) begin
    if (clk_en) begin
        clken_next = 1'b1;
    end else if (clk_end) begin
        clken = 1'b0;
    end else begin
        clken = clken;
    end
  end

  // Start signal logic
  always@(*) begin
    if (clken && !en_before) begin
        start_in_next = 1'b1;
    end else begin
        start_in_next = 1'b0;
    end
  end

  assign clk_o = clk_i & clken;

endmodule