module logic_top#(
    parameter APB_ADDR_WIDTH = 12  //APB slaves are 4KB by default
)(
    input  clk,
    input  rst,
	input  read_n,
	input  ALU_en,
	input  [31:0] PWDATA,
	input  [1 :0] col_counter,
	input  load_en,
	input  [APB_ADDR_WIDTH-1:0] r_addr,
    input  valid_input,
    
    output ry,
	output cal_finish,
	output [31:0] data_out,
    output load_done
);

// input matrix wire
wire [63:0] 	X_reg1;
wire [63:0] 	X_reg2;
wire [63:0] 	X_reg3;



// when web, a sub calculation is finished
assign cal_finish = web;

X_buffer u_X_buffer(
	.clk           	( clk            ),
	.rst           	( rst            ),
	.valid_input   	( valid_input    ),
	.load_en 	    ( load_en        ),
	.X_shift       	( ALU_en         ),
	.X_load        	( PWDATA         ),
	.col_counter    ( col_counter    ),
	.X_reg1        	( X_reg1         ),
	.X_reg2        	( X_reg2         ),
	.X_reg3        	( X_reg3         ),
	.load_done    	( load_done      )
);

// outports wire
wire [7:0]   	A_input;
wire [3:0]      rom_addr;

A_rom u_A_rom(
	.clk     	( clk       ),
	.rst     	( rst       ),
	.rom_addr   ( rom_addr  ),
	.A_input 	( A_input   )
);

// outports wire
wire [17:0] 	MU1;
wire [17:0] 	MU2;
wire [17:0] 	MU3;
wire [17:0] 	MU4;
wire [17:0] 	MU5;
wire [17:0] 	MU6;
wire [17:0] 	MU7;

ALU u_ALU(
	.clk       	( clk        ),
	.rst       	( rst        ),
	.A_input   	( A_input    ),
	.col_counter( col_counter),
	.ALU_en     ( ALU_en     ),
	.X_reg1    	( X_reg1     ),
	.X_reg2    	( X_reg2     ),
	.X_reg3    	( X_reg3     ),
	.MU1       	( MU1        ),
	.MU2       	( MU2        ),
	.MU3       	( MU3        ),
	.MU4       	( MU4        ),
	.MU5       	( MU5        ),
	.MU6       	( MU6        ),
	.MU7       	( MU7        ),
	.web        ( web        ),
    .rom_addr   ( rom_addr   )
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
