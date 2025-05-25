module top_top_test(
    input  clk,
    input  rst,
	input  cs_n,
    input  start_in,
    input  valid_input,
    input  [7:0] X_load,
    
    output ry,
	output [31:0]read_data,
    output finish
);

// outports wire
wire        ALU_done;
wire       	xload_done;
wire       	input_load_en;


controller u_controller(
	.clk             	( clk              ),
	.rst             	( rst              ),
	.start_in        	( start_in         ),
	.ALU_done 	        ( ALU_done         ),
	.web                ( web              ),
	.xload_done      	( xload_done       ),
	.ALU_en             ( ALU_en           ),
	.input_load_en   	( input_load_en    ),
	.finish          	( finish           )
);

logic_top_test u_logic_top_test(
	.clk             	( clk              ),
	.rst             	( rst              ),
	.cs_n               ( cs_n             ),
	.ALU_en             ( ALU_en           ),
	.X_load         	( X_load           ),
	.valid_input     	( valid_input      ),
	.input_load_en   	( input_load_en    ),
	
	.web                ( web              ),
	.xload_done      	( xload_done       ),
	.ry                 ( ry               ),
    .read_data          ( read_data        ),
	.ALU_done 	        ( ALU_done         )
);

endmodule