
`define ACC_EN_VALUE               32'd1    // enable clock gating
`define ACC_END_VALUE              32'd0    // disable clock gating

`define ACC_EN_ADDR                13'b1111111111111
`define ACC_LOAD_A_ADDR            13'd1    // load A to ALU
`define ACC_LOAD_X_ADDR            13'd2    // load X to ALU
`timescale 1ns / 1ns
module acc_top
#(
    parameter APB_ADDR_WIDTH = 13  //APB slaves are 8KB by default
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
wire clk_en, clk_end ,start_in, write_A_n, write_X_n;
assign acc_write = PSEL && PENABLE && PWRITE;
assign clk_en    = acc_write && (PWDATA == `ACC_EN_VALUE )&& (PADDR == `ACC_EN_ADDR); // enable clock gating
assign clk_end   = acc_write && (PWDATA == `ACC_END_VALUE)&& (PADDR == `ACC_EN_ADDR); // disable clock gating
assign write_A_n = acc_write && (PADDR == `ACC_LOAD_A_ADDR) ? 1'b1 : 1'b0;
assign write_X_n = acc_write && (PADDR == `ACC_LOAD_X_ADDR) ? 1'b1 : 1'b0;

//read enable and write enable
wire   read_n;
assign read_n  = (PSEL && PENABLE && !PWRITE) ? 1'b1 : 1'b0;
wire   rst;

clock_gate clk_gate_inst (
    .clk_i   ( HCLK          ),
    .rst     ( HRESETn       ),
    .clk_en  ( clk_en        ),
    .clk_end ( clk_end       ),
    .start_in( start_in      ),
	.rst_o   ( rst           ),
    .clk_o   ( clk           )
);

// output mux
//reg pslverr;
//wire pready;
wire [31:0] prdata;
assign PRDATA   = read_n ? prdata : 32'b0;
//assign PSELVERR = PSEL ? pslverr : 1'b0;
assign PSLVERR  = 1'b0;
assign PREADY   = pready;
//assign PREADY   = 1'b1;

// outports wire
wire       	ALU_en;
wire       	load_en;
wire       	row_finish;
wire [4:0] 	row_count;
wire ry_o; 

controller u_controller(
	.clk        	( clk         ),
	.rst        	( rst         ),
	.ry_o           ( ry_o        ),
	.start_in   	( start_in    ),
	.load_done  	( load_done   ),
	.load_A_done	( load_A_done ),
	.pready	 	    ( pready      ),
	.ALU_en     	( ALU_en      ),
	.load_en    	( load_en     ),
	.load_A_en 	    ( load_A_en   ),
	.row_finish 	( row_finish  ),
	.row_count  	( row_count   )
	
);

// outports wire
wire [19:0] 	sum;
wire        	web;
wire [71:0] 	A_input;
wire [23:0] 	X_reg1;
wire [23:0] 	X_reg2;
wire [23:0] 	X_reg3;

ALU u_ALU(
	.clk     	( clk      ),
	.rst     	( rst      ),
	.ALU_en  	( ALU_en   ),
	.A_input 	( A_input  ),
	.X_reg1  	( X_reg1   ),
	.X_reg2  	( X_reg2   ),
	.X_reg3  	( X_reg3   ),
	.sum     	( sum      ),
	.web     	( web      )
);

A_buffer u_A_buffer(
	.clk        	( clk         ),
	.rst        	( rst         ),
	.PWDATA     	( PWDATA      ),
	.valid_input 	( write_A_n   ),
	.load_A_en 	    ( load_A_en   ),
	.load_A_done    ( load_A_done ),
	.A_input    	( A_input     )
);

X_buffer u_X_buffer(
	.clk         	( clk          ),
	.rst         	( rst          ),
	.ALU_en      	( ALU_en       ),
	.load_en     	( load_en      ),
	.valid_input 	( write_X_n    ),
	.X_load      	( PWDATA       ),
	.row_count  	( row_count    ),
	.row_finish 	( row_finish   ),
	.X_reg1      	( X_reg1       ),
	.X_reg2      	( X_reg2       ),
	.X_reg3      	( X_reg3       ),
	.load_done   	( load_done    )
);

// outports wire
wire [31:0] dataRAM;
wire [APB_ADDR_WIDTH-1:0] 	w_addr;

wb u_wb(
	.clk     	( clk      ),
	.rst     	( rst      ),
	.web     	( web      ),
	.sum      	( sum      ),
	.w_addr  	( w_addr   ),
	.dataRAM 	( dataRAM  )
);
//wire ry_o; 
acc_ram u_acc_ram(
	.clk     	( HCLK          ),
	.en_i    	( web||read_n   ),
	.we_i    	( ~web          ),
	.w_addr_i  	( w_addr        ),
	.r_addr_i  	( PADDR         ),
	.wdata_i 	( dataRAM       ),
	.rdata_o 	( prdata        ),
	.ry_o    	( ry_o          )
);


endmodule

