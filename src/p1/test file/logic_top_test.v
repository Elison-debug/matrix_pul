module logic_top_test(
    input  clk,
    input  rst,
	input  cs_n,
	input  ALU_en,
    input  input_load_en,
	
    input  [7:0] X_load,
    input  valid_input,
    
    output ry,
	output web,
	output ALU_done,
    output xload_done,
    output [31:0]read_data
);

// outports wire
wire [7:0] 	X_reg1;
wire [7:0] 	X_reg2;
wire [7:0] 	X_reg3;
wire [7:0] 	X_reg4;

X_buffer u_X_buffer(
	.clk           	( clk            ),
	.rst           	( rst            ),
	.valid_input   	( valid_input    ),
	.input_load_en 	( input_load_en  ),
	.X_load        	( X_load         ),
	.X_shift       	( X_shift        ),
	.X_reg1        	( X_reg1         ),
	.X_reg2        	( X_reg2         ),
	.X_reg3        	( X_reg3         ),
	.X_reg4        	( X_reg4         ),
	.xload_done    	( xload_done     )
);

// outports wire
wire [13:0] 	A_input;
wire [3:0]      rom_addr;

A_rom_test u_A_rom_test(
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

ALU u_ALU(
	.clk       	( clk        ),
	.rst       	( rst        ),
	.A_input   	( A_input    ),
	.ALU_en     ( ALU_en     ),
	.X_reg1    	( X_reg1     ),
	.X_reg2    	( X_reg2     ),
	.X_reg3    	( X_reg3     ),
	.X_reg4    	( X_reg4     ),
	.X_shift   	( X_shift    ),
	.MU1       	( MU1        ),
	.MU2       	( MU2        ),
	.MU3       	( MU3        ),
	.MU4       	( MU4        ),
	.web        ( web        ),
	.ALU_done   ( ALU_done   ),
    .rom_addr   ( rom_addr   )
);


// wb outports wire

wire [7:0]      address;
wire [31:0] 	dataRAM;

wb u_wb(
	.clk     	( clk      ),
	.rst     	( rst      ),
	.web     	( web      ),
	.MU1     	( MU1      ),
	.MU2     	( MU2      ),
	.MU3     	( MU3      ),
	.MU4     	( MU4      ),
	.ram_en  	( ram_en   ),
	.address 	( address  ),
	.dataRAM 	( dataRAM  ) 
);

sram_wrapper u_sram_wrapper(
    .clk        (clk       ),
    .cs_n       (cs_n      ),
    .we_n       (ram_en    ),
    .address    (address   ),
    .write_data (dataRAM   ),
    .ry         (ry        ),
    .read_data  (read_data )
);

endmodule