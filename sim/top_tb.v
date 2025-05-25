module top_tb();
    parameter MAIN_FRE   = 100; //unit MHz

    localparam matrix_num = 2;   //total matrix number       
    localparam NUM_KEYS = matrix_num*32;   //total data num

    localparam INPUT_FILE = "X_input.txt";
    localparam RESULT_FILE = "result.txt";
    reg [7:0] memory [0:NUM_KEYS-1]; // 8 bit memory with 32 * matrix_num entries
    reg [17:0] result_data [0:matrix_num*16-1]; // 18 bit result with 16 * matrix_num entries
    reg [17:0] result_data_ALU [0:matrix_num*16-1]; // 18 bit result with 16 * matrix_num entries

    //FSM state
    parameter IDLE = 2'b00;
    parameter X_input = 2'b01;
    parameter next_input = 2'b10;

    reg [7:0] r_addr;
    reg [1:0] state;
    reg [1:0] state_next;

    //clock
    reg clk = 0;
    reg rst = 0;

    // test input signal
    reg start_in=0;
    reg read_n=1'b1;
    reg [matrix_num+4:0] matrix_count;
    reg [matrix_num+4:0] matrix_count_next;

    wire ry;
    wire valid_input;
    
    wire [7:0] X_load;
    assign valid_input = (state == X_input);
    assign X_load =(state == X_input)? memory[matrix_count]:0;

    // outports wire
    wire       	finish; 
    wire [8:0]  data_out;

always #(500/MAIN_FRE) clk = ~clk;
integer i=0;

initial begin
    $readmemb(INPUT_FILE, memory);
    $readmemb(RESULT_FILE, result_data);
    rst = 1'b0;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    rst = 1'b1;
    r_addr    = 0;
    #100 start_in=1'b1;

    #3000
    for (i = 0; i < matrix_num*16; i = i + 1) begin
            @(posedge clk);
            r_addr = i;
            read_n = 1'b0;
            @(posedge clk);
            read_n = 1'b1;
            repeat (2) @(posedge clk);
            result_data_ALU[i] [8:0] = data_out;
            @(posedge clk);
            result_data_ALU[i] [17:9] = data_out;
            if(result_data_ALU[i] != result_data[i])begin
                $display("Error: result_data[%d] = %b, result_data_ALU[%d] = %b", i, result_data[i], i, result_data_ALU[i]);
            end
            $display("Time %0t: Address = %d, data_out_ALU = %b", $time, i, result_data_ALU[i]);
        end

        #50;
        $display("Time %0t: Congratulations!! results are all correct!!", $time);
        $finish;
end
    
always @(posedge clk or negedge rst) begin
    if(!rst)begin
        state  <= IDLE;
        matrix_count <= 0; 
    end
    else begin
        state <= state_next;
        matrix_count <= matrix_count_next; 
    end
end

always @(*) begin
    state_next = state;
    matrix_count_next = matrix_count;
    case (state)
        IDLE       : begin state_next = start_in ? X_input : IDLE;  end
        X_input    : begin state_next = (matrix_count[4:0]==5'd31) ? next_input : X_input; 
            start_in = 0; 

            matrix_count_next = matrix_count + 1'b1;
        end
        next_input : begin
            if(matrix_count[matrix_num+4:5]==matrix_num)begin
                state_next = IDLE;
            end
            else if (finish) begin
                @(negedge clk);
                @(negedge clk);
                @(negedge clk);
                start_in =1'b1;
                @(negedge clk);
                start_in =1'b0;
                state_next = X_input;
            end
        end
        default : state  <= IDLE;
    endcase
end

top u_top(
	.clk         	( clk          ),
	.rst         	( rst          ),
    .read_n         ( read_n       ),
	.start_in    	( start_in     ),
	.valid_input 	( valid_input  ),
    .r_addr         ( r_addr       ),
	.X_load      	( X_load       ),
    .ry             ( ry           ),
    .data_out       ( data_out     ),
	.finish      	( finish       )
);



endmodule  //TOP
