
`define ACC_EN_VALUE               32'd1    // enable clock gating
`define ACC_END_VALUE              32'd0    // disable clock gating

`define ACC_LOAD_A_ADDR            13'd1    // load A to ALU
`define ACC_LOAD_X_ADDR            13'd2    // load X to ALU
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
assign clk_en    = acc_write && (PWDATA == `ACC_EN_VALUE )&& (PADDR == 12'h0); // enable clock gating
assign clk_end   = acc_write && (PWDATA == `ACC_END_VALUE)&& (PADDR == 12'h0); // disable clock gating
assign write_A_n = acc_write && (PADDR == `ACC_LOAD_A_ADDR) ? 1'b1 : 1'b0;
assign write_X_n = acc_write && (PADDR == `ACC_LOAD_X_ADDR) ? 1'b1 : 1'b0;

//read enable and write enable
wire   read_n;
assign read_n  = (PSEL && PENABLE && !PWRITE) ? 1'b1 : 1'b0;

wire   rst;
assign rst = HRESETn;

clock_gate clk_gate_inst (
    .clk_i   ( HCLK          ),
    .rst     ( rst           ),
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
assign PREADY   = 1'b1;

// outports wire
wire       	ALU_en;
wire       	pready;
wire       	load_en;
wire       	row_finish;
wire       	acc_finish;
wire [4:0] 	col_count;
wire [1:0] 	row_count;

controller u_controller(
	.clk        	( clk         ),
	.rst        	( rst         ),
	.start_in   	( start_in    ),
	.load_done  	( load_done   ),
	.load_A_done	( load_A_done ),
	.ALU_en     	( ALU_en      ),
	.load_en    	( load_en     ),
	.load_A_en 	    ( load_A_en   ),
	.row_finish 	( row_finish  ),
	.acc_finish 	( acc_finish  ),
	.col_count  	( col_count   ),
	.row_count  	( row_count   )
	
);


// outports wire
wire [20:0] 	sum;
wire        	web;

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
	.X_load      	( X_load       ),
	.row_counter 	( row_counter  ),
	.X_reg1      	( X_reg1       ),
	.X_reg2      	( X_reg2       ),
	.X_reg3      	( X_reg3       ),
	.load_done   	( load_done    )
);

// outports wire
wire        	we_n;
wire [7:0]  	w_addr;
wire [31:0] 	dataRAM;

wb u_wb(
	.clk     	( clk      ),
	.rst     	( rst      ),
	.web     	( web      ),
	.sum      	( sum      ),
	.w_addr  	( w_addr   ),
	.dataRAM 	( dataRAM  )
);

// outports wire
wire [31:0] 	rdata_o;

acc_ram u_acc_ram(
	.clk     	( clk         ),
	.en_i    	( web||read_n ),
	.w_addr_i  	( w_addr      ),
	.r_addr_i  	( PADDR       ),
	.wdata_i 	( dataRAM     ),
	.rdata_o 	( prdata      ),
	.we_i    	( !web        )
);


endmodule

