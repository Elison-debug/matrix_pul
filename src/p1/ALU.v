module ALU(
    input  clk,
    input  rst,

    input [13:0] A_input,
    input [7:0] X_reg1,        // Input 8*8bit elemments per row of the input matrix 
    input [7:0] X_reg2,
    input [7:0] X_reg3,  
    input [7:0] X_reg4,
    input       ALU_en,
               // sychronized the input resgister in the buffer. 
    output [17:0] MU1,     // output result for each mul-sum product seperately
    output [17:0] MU2,
    output [17:0] MU3,
    output [17:0] MU4,
    output [3:0] rom_addr,     // Read coe from the ROM to the ALU, calculate the address to indicate the coe that the ROM need.     
    output web,
    output ALU_done   
);  
    // Reg for the mul op counter. 
    reg [4:0] counter, counter_next;
    assign rom_addr  = counter_next[4:1];

    //finish and web signal
    assign ALU_done= (counter[4:0] == 5'd31);
    assign web     = (counter[2:0] == 3'd7);

    // MU Reg
    reg [17:0]  MU1_r;
    reg [17:0]  MU2_r;
    reg [17:0]  MU3_r;
    reg [17:0]  MU4_r;

    reg [17:0]  MU1_next,MU2_next,MU3_next,MU4_next;
    assign MU1 = MU1_next;
    assign MU2 = MU2_next;
    assign MU3 = MU3_next;
    assign MU4 = MU4_next;

    // signal connection
    wire [6:0]  data_even = A_input [13:7];
    wire [6:0]  data_odd  = A_input [6:0];
    wire [6:0]  A;
    assign A = (counter[0] == 1) ? data_odd : data_even;

    // cl and rst. 
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            MU1_r <= 0; MU2_r <= 0; MU3_r <= 0; MU4_r <= 0;
            counter <= 0; 
        end
        else begin
                counter <= counter_next;
                MU1_r <= MU1_next; 
                MU2_r <= MU2_next; 
                MU3_r <= MU3_next; 
                MU4_r <= MU4_next;
        end
    end

    // ALU
    always @(*) begin
        // Default value.
        counter_next = counter;
        if (ALU_en) begin
            counter_next = counter + 1;
            MU1_next = A*X_reg1 + MU1_r;
            MU2_next = A*X_reg2 + MU2_r;
            MU3_next = A*X_reg3 + MU3_r;
            MU4_next = A*X_reg4 + MU4_r;
        end
        else begin
            // Finish the multiply and back to controller IDLE. Prepare to next input matrix.
            MU1_next = 18'b0; MU2_next = 18'b0; MU3_next = 18'b0; MU4_next = 18'b0; 
        end
    end 

endmodule
