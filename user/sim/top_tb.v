`define ACC_EN_VALUE               32'd1    // enable clock gating
`define ACC_END_VALUE              32'd0    // disable clock gating
`define ACC_EN_ADDR                13'h0x1fff
`define ACC_LOAD_A_ADDR            13'd1    // load A to ALU
`define ACC_LOAD_X_ADDR            13'd2    // load X to ALU
`timescale 1ns / 1ns
module top_tb();
    parameter MAIN_FRE   = 100; //unit MHz
  
    localparam matrix_num = 2;   //total matrix number 
    localparam A_NUM = 3*3;   //total data num
    localparam X_NUM = 28*28;   //total data num

    //localparam X_NUM_KEYS = $clog2(matrix_num*28*28);   //total data num
    //localparam A_NUM_KEYS = $clog2(matrix_num*3*3);   //total data num

    localparam A_INPUT = "filter_matrix_all_bin.txt";
    localparam X_INPUT = "input_matrix_all_bin.txt";
    localparam RESULT_FILE = "conv_output_all_bin.txt";

    reg [7:0] A_memory [0:matrix_num*A_NUM-1];
    reg [7:0] X_memory [0:matrix_num*X_NUM-1]; // 8 bit memory with 32 * matrix_num entries
    reg [19:0] result_data     [0:matrix_num*28*28-1]; // 18 bit result with 16 * matrix_num entries
    reg [19:0] result_data_ALU [0:matrix_num*28*28-1]; // 18 bit result with 16 * matrix_num entries

    // APB signals
    reg  [12:0] PADDR;
    reg         PSEL;
    reg         PENABLE;
    reg         PWRITE;
    reg  [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire        PREADY;

    //clock
    reg clk = 0;
    reg rst = 0;

always #(500/MAIN_FRE) clk = ~clk;
integer i=0;

initial begin
    $display("Simulation started");
    $readmemb(A_INPUT, A_memory);
    $readmemb(X_INPUT, X_memory);
    $readmemb(RESULT_FILE, result_data);
    // Initialize apb signals
    PADDR   = 32'b0;
    PWDATA  = 32'b0;
    PWRITE  = 0;
    PSEL    = 0;
    PENABLE = 0;

    rst = 1'b0;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    rst = 1'b1;

    #100
    apb_write(`ACC_EN_ADDR, `ACC_EN_VALUE); // Enable clock gating
    //apb_write(13'b0, `ACC_END_VALUE); // Disable clock gating
    write_A(0); // Load A matrix
    write_X(0); // Load X matrix

    #100;
    for (i = 0; i < 28*28-1; i = i + 1) begin
      apb_read (4*i);
      //$display("Time %0t: Address = %d, data_out_ALU = %b", $time, i, result_data_ALU[i]);
    end

    #100;

    write_A(A_NUM); // Load A matrix 2
    write_X(X_NUM); // Load X matrix 2

    #3000;
    for (i = 0; i < 28*28-1; i = i + 1) begin
      apb_read (4*i);
      //$display("Time %0t: Address = %d, data_out_ALU = %b", $time, i, result_data_ALU[i]);
    end

      #50;
      $display("Time %0t: Congratulations!! results are all correct!!", $time);
      $finish;
end
  integer j;
  task write_A(input integer index);
    begin
        for (j = index; j < A_NUM+index; j = j + 4) begin
          if (j != 8) begin
            apb_write(`ACC_LOAD_A_ADDR, {A_memory[j], A_memory[j+1], A_memory[j+2], A_memory[j+3]});
            @(posedge clk);
          end
          else begin
            apb_write(`ACC_LOAD_A_ADDR, {24'b0,A_memory[j]});
            @(posedge clk);
          end
        end
        $display("A matrix loaded successfully.");
    end
  endtask

  task write_X(input integer index);
    begin
        for (j = index; j < X_NUM +index; j = j + 4) begin
            apb_write(`ACC_LOAD_X_ADDR, {X_memory[j], X_memory[j+1], X_memory[j+2], X_memory[j+3]});
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
      //$display("APB WRITE successful: Addr=0x%08X, Data=0x%08X", addr, data);
    end
  endtask

  // APB Read Task
  task apb_read(input [12:0] addr);
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

      if(PRDATA != result_data[addr[12:2]])begin
        $display("Error: result_data[%d] = %b, result_data_ALU[%d] = %b", i, result_data[i], i, result_data_ALU[i]);
      end
      //$display("APB READ : Addr=0x%08X, Data=0x%08X", addr, PRDATA);

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
