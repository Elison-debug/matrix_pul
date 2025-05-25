module top(
    input             clk,          
    input             rst,          
    input             read_n,       
    input             start_in,     
    input             valid_input,  
    input      [7:0]  r_addr,       // Address input
    input      [7:0]  X_load,       // X load signal
    output            ry,           
    output     [8:0]  data_out,    // Read data output
    output            finish     // ALU done flag (goes to finish pad)
);

  // Internal signals
  wire web;
  wire xload_done;
  wire ALU_en;
  wire input_load_en;

  controller controller_inst (
      .clk           (clk          ),
      .rst           (rst          ),
      .start_in      (start_in     ),
      .web           (web          ),
      .xload_done    (xload_done   ),
      .ALU_en        (ALU_en       ),
      .input_load_en (input_load_en)
  );

  logic_top logic_top_inst (
      .clk           ( clk          ),
      .rst           ( rst          ),
      .read_n        ( read_n       ),
      .ALU_en        ( ALU_en       ),
      .r_addr        ( r_addr       ),
      .X_load        ( X_load       ),
      .valid_input   ( valid_input  ),
      .input_load_en ( input_load_en),
      .web           ( web          ),
      .xload_done    ( xload_done   ),
      .ry            ( ry           ),
      .data_out      ( data_out     ),
      .ALU_done      ( finish       )
  );

endmodule
