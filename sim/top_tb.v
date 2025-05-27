`define ACC_EN_VALUE               32'd1    // enable clock gating
`define ACC_END_VALUE              32'd0    // disable clock gating

`define ACC_LOAD_A_ADDR            13'd1    // load A to ALU
`define ACC_LOAD_X_ADDR            13'd2    // load X to ALU
module top_tb();
    parameter MAIN_FRE   = 100; //unit MHz

    localparam matrix_num = 2;   //total matrix number 
    localparam A_NUM = matrix_num*3*3;   //total data num
    localparam X_NUM = matrix_num*28*28;   //total data num

    localparam X_NUM_KEYS = $clog2(matrix_num*28*28);   //total data num
    localparam A_NUM_KEYS = $clog2(matrix_num*3*3);   //total data num

    localparam A_INPUT = "A_input.txt";
    localparam X_INPUT = "X_input.txt";
    localparam RESULT_FILE = "result.txt";

    reg [31:0] A_memory [0:A_NUM_KEYS-3];
    reg [31:0] X_memory [0:X_NUM_KEYS-3]; // 8 bit memory with 32 * matrix_num entries
    reg [19:0] result_data     [0:matrix_num*28*28-1]; // 18 bit result with 16 * matrix_num entries
    reg [19:0] result_data_ALU [0:matrix_num*28*28-1]; // 18 bit result with 16 * matrix_num entries

    //FSM state
    parameter IDLE = 2'b00;
    parameter X_input = 2'b01;
    parameter next_input = 2'b10;

    // APB signals
    reg  [12:0] PADDR;
    reg         PSEL;
    reg         PENABLE;
    reg         PWRITE;
    reg  [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire        PREADY;

    reg [1:0] state;
    reg [1:0] state_next;

    //clock
    reg clk = 0;
    reg rst = 0;

    reg [$clog2(X_NUM_KEYS)-1:0] matrix_count;
    reg [$clog2(X_NUM_KEYS)-1:0] matrix_count_next;
    
    wire [7:0] X_load;
    wire [7:0] A_load;

    assign A_load =(state == A_input)? memory[matrix_count]:0;
    assign X_load =(state == X_input)? memory[matrix_count]:0;

    // outports wire
    wire       	finish; 

always #(500/MAIN_FRE) clk = ~clk;
integer i=0;

initial begin
    $display("Simulation started");
    $readmemb(A_INPUT, A_memory);
    $readmemb(X_INPUT, X_memory);
    $readmemb(RESULT_FILE, result_data);

    rst = 1'b0;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    rst = 1'b1;

    #100
    apb_write(13'b0, `ACC_EN_VALUE); // Enable clock gating
    //apb_write(13'b0, `ACC_END_VALUE); // Disable clock gating
    write_A(0); // Load A matrix
    write_X(0); // Load X matrix

    #100;
    for (i = 0; i < 28*28-1; i = i + 1) begin
        result_data_ALU[i] = PRDATA[19:0];
        if(result_data_ALU[i] != result_data[i])begin
            $display("Error: result_data[%d] = %b, result_data_ALU[%d] = %b", i, result_data[i], i, result_data_ALU[i]);
            $finish;
        end
        //$display("Time %0t: Address = %d, data_out_ALU = %b", $time, i, result_data_ALU[i]);
    end

    #100;

    write_A(A_NUM); // Load A matrix 2
    write_X(X_NUM); // Load X matrix 2

    #100;
    for (i = 0; i < 28*28-1; i = i + 1) begin
        result_data_ALU[i] = PRDATA[19:0];
        if(result_data_ALU[i] != result_data[i])begin
            $display("Error: result_data[%d] = %b, result_data_ALU[%d] = %b", i, result_data[i], i, result_data_ALU[i]);
            $finish;
        end
        //$display("Time %0t: Address = %d, data_out_ALU = %b", $time, i, result_data_ALU[i]);
    end
        #50;
        $display("Time %0t: Congratulations!! results are all correct!!", $time);
        $finish;
end

  task write_A(input integer index);
    begin
        integer j;
        for (j = index; j < A_NUM+index; j = j + 1) begin
            apb_write(`ACC_LOAD_A_ADDR, A_memory[j]);
            @(posedge clk);
        end
        $display("A matrix loaded successfully.");
    end
  endtask

  task write_X(input integer index);
    begin
        integer j;
        for (j = index; j < X_NUM+index; j = j + 1) begin
            apb_write(`ACC_LOAD_X_ADDR, X_memory[j]);
            @(posedge clk);
        end
        $display("X matrix loaded successfully.");
    end
  endtask

// APB Write Task
  task apb_write(input [12:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      PADDR   = addr;
      PWDATA  = data;
      PWRITE  = 1;
      PSEL    = 1;
      PENABLE = 0;

      @(posedge clk);
      PENABLE = 1;

      wait (PREADY == 1);
      @(posedge clk);

      PSEL    = 0;
      PENABLE = 0;
      PWRITE  = 0;
      $display("APB WRITE successful: Addr=0x%08X, Data=0x%08X", addr, data);
    end
  endtask

  // APB Read Task
  task apb_read(input [31:0] addr);
    begin
      @(posedge clk);
      PADDR   = addr;
      PWRITE  = 0;
      PSEL    = 1;
      PENABLE = 0;

      @(posedge clk);
      PENABLE = 1;

      wait (PREADY == 1);
      @(posedge clk);

      $display("APB READ : Addr=0x%08X, Data=0x%08X", addr, PRDATA);

      PSEL    = 0;
      PENABLE = 0;
    end
  endtask

    acc_top u_acc_top(
        .HCLK    	( clk      ),
        .HRESETn 	( rst      ),
        .PADDR   	( PADDR    ),
        .PWDATA  	( PWDATA   ),
        .PWRITE  	( PWRITE   ),
        .PSEL    	( PSEL     ),
        .PENABLE 	( PENABLE  ),
        .PRDATA  	( PRDATA   ),
        .PREADY  	( PREADY   ),
        .PSLVERR 	( PSLVERR  )
    );


endmodule  //TOP
