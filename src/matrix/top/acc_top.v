
`define ACC_EN_VALUE               32'd1    // enable clock gating
`define ACC_END_VALUE              32'd0    // disable clock gating
module acc_top
#(
    parameter APB_ADDR_WIDTH = 12  //APB slaves are 4KB by default
)(
    input                        HCLK,
    input                        HRESETn,
    input   [APB_ADDR_WIDTH-1:0] PADDR,
    input                 [31:0] PWDATA,
    input                        PWRITE,
    input                        PSEL,
    input                        PENABLE,
    output                [31:0] PRDATA,
    output                       PREADY,
    output                       PSLVERR
);

// Clock gating
wire clk_en, clk_end, acc_sel ,start_in;
assign acc_sel = PSEL    && PENABLE;
assign clk_en  = acc_sel && PWRITE && (PWDATA == `ACC_EN_VALUE )&& (PADDR == 12'h0); // enable clock gating
assign clk_end = acc_sel && PWRITE && (PWDATA == `ACC_END_VALUE)&& (PADDR != 12'h0); // disable clock gating

//read enable and write enable
wire   read_n, write_n;
assign read_n  = (acc_sel &&  PWRITE) ? 1'b0 : 1'b1;
assign write_n = (acc_sel && !PWRITE) ? 1'b1 : 1'b0;

clock_gate clk_gate_inst (
    .clk_i   ( HCLK          ),
    .rst     ( HRESETn       ),
    .clk_en  ( clk_en        ),
    .clk_end ( clk_end       ),
    .start_in( start_in      ),
    .clk_o   ( clk           )
);

// output mux
reg pslverr;
reg [31:0] prdata;
always @(*) begin
    if (PSEL != 1'b0)
        begin
            PRDATA = prdata;
            PSLVERR = pslverr;
        end
    else begin
            PRDATA = 32'0;
            PSLVERR = 1'b0;
        end
end

  // Internal signals
  wire load_done;


  controller controller_inst (
      .clk           ( clk          ),
      .rst           ( HRESETn      ),
      .start_in      ( start_in     ),
      .load_done     ( load_done    ),
      .cal_finish    ( cal_finish   ),
      .col_counter   ( col_counter  ),
      .ALU_en        ( ALU_en       ),
      .acc_finish    ( acc_finish   ),
      .pready        ( PREADY       ),
      .load_en       ( load_en      )
  );

  logic_top 
  #(
    .APB_ADDR_WIDTH(12)
  ) 
    logic_top_inst 
  (
      .clk           ( clk          ),
      .rst           ( HRESETn      ),  
      .read_n        ( read_n       ),
      .ALU_en        ( ALU_en       ),
      .load_en       ( load_en      ),
      .r_addr        ( PADDR        ),
      .PWDATA        ( PWDATA       ),
      .col_counter   ( col_counter  ),   
      .valid_input   ( write_n      ),
      .load_done     ( load_done    ),
      .cal_finish    ( cal_finish   ),
      .ry            ( ry           ),
      .data_out      ( data_out     )
  );


endmodule

