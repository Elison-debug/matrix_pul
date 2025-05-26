
`define ACC_EN_VALUE               32'd1    // enable clock gating
`define ACC_END_VALUE              32'd0    // disable clock gating
module acc_top
#(
    parameter APB_ADDR_WIDTH = 13  //APB slaves are 4KB by default
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
wire rst;
assign rst = HRESETn;

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
assign PRDATA   = PSEL ? prdata : 32'b0;
//assign PSELVERR = PSEL ? pslverr : 1'b0;
assign PSLVERR  = 1'b0;

  // Internal signals
  wire load_done,shift_count, acc_counter;
  controller controller_inst (
      .clk           ( clk          ),
      .rst           ( rst          ),
      .start_in      ( start_in     ),
      .load_done     ( load_done    ),
      .cal_finish    ( web          ),// when web, a sub calculation is finished
      .shift_counter ( shift_count     ),
      .acc_counter   ( acc_counter  ),
      .ALU_en        ( ALU_en       ),
      .acc_finish    ( acc_finish   ),
      .pready        ( PREADY       ),
      .load_en       ( load_en      )
  );

// outports wire
wire [17:0] 	MU1;
wire [17:0] 	MU2;
wire [17:0] 	MU3;
wire [17:0] 	MU4;

wire [7:0]   	A_input;
wire [3:0]    rom_addr;

ALU u_ALU(
	.clk       	( clk        ),
	.rst       	( rst        ),
	.A_input   	( A_input    ),
	.ALU_en     ( ALU_en     ),
	.X_reg1    	( X_reg1     ),
	.X_reg2    	( X_reg2     ),
	.X_reg3    	( X_reg3     ),
	.X_reg4    	( X_reg4     ),
	.MU1       	( MU1        ),
	.MU2       	( MU2        ),
	.MU3       	( MU3        ),
	.MU4       	( MU4        ),
	.web        ( web        ),
  .addr_offset( addr_offset   )
);

A_rom u_A_rom(
	.clk     	( clk       ),
	.rst     	( rst       ),
	.rom_addr ( rom_addr  ),
	.A_input 	( A_input   )
);

// input matrix wire
wire [63:0] 	X_reg1;
wire [63:0] 	X_reg2;
wire [63:0] 	X_reg3;
wire [63:0] 	X_reg4;

X_buffer u_X_buffer(
	.clk           	( clk            ),
	.rst           	( rst            ),
	.valid_input   	( valid_input    ),
	.load_en 	      ( load_en        ),
  .X_shift       	( ALU_en         ),
	.X_load        	( PWDATA         ),
  .shift_count     ( shift_count    ),
	.acc_counter    ( acc_counter    ),
	.X_reg1        	( X_reg1         ),
	.X_reg2        	( X_reg2         ),
	.X_reg3        	( X_reg3         ),
	.X_reg4        	( X_reg4         ),
	.load_done    	( load_done      )
);


// wb outports wire
wire [7:0 ]     w_addr;
wire [31:0] 	dataRAM;


wb u_wb(
	.clk     	( clk      ),
	.rst     	( rst      ),
	.web     	( web      ),
	.MU1     	( MU1      ),
	.MU2     	( MU2      ),
	.MU3     	( MU3      ),
	.MU4     	( MU4      ),
	.we_n  	    ( we_n     ),
	.w_addr 	( w_addr   ),
	.dataRAM 	( dataRAM  ) 
);

sram_mem u_sram_mem(
	.clk        	( clk         ),
	.rst        	( rst         ),
	.we_n       	( we_n        ),
	.read_n     	( read_n      ),
	.w_addr     	( w_addr      ),
	.r_addr     	( r_addr      ),
	.write_data 	( dataRAM     ),
	.ry         	( ry          ),
	.data_out   	( data_out    )
);


endmodule

