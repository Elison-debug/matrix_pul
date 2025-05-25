module ALU(
    input  clk,
    input  rst,

    input [7:0]  A_input,
    input [7:0]  X_reg1,    // Input 4*8bit elemments 
    input [7:0]  X_reg2,
    input [7:0]  X_reg3, 
    input [7:0]  X_reg4, 
    input        ALU_en,    
    input  [1:0 ] col_counter,
    output [19:0] MU1,     // output result for each mul-sum product seperately
    output [19:0] MU2,
    output [19:0] MU3,
    output [19:0] MU4,     // output result for each mul-sum product seperately
    output [3:0] rom_addr,     // Read coe from the ROM to the ALU, calculate the address to indicate the coe that the ROM need.     
    output web 
);  
    // Reg for the mul op counter. 
    reg [3:0] counter, counter_next;
    assign rom_addr  = counter_next;

    //finish and web signal
    assign web  = (counter == 3'b1000);

    // MU Reg
    reg [19:0]  MU1_r;
    reg [19:0]  MU2_r;
    reg [19:0]  MU3_r;
    reg [19:0]  MU4_r;
  

    reg [19:0]  MU1_next,MU2_next,MU3_next,MU4_next;

    assign MU1 = MU1_next;
    assign MU2 = MU2_next;
    assign MU3 = MU3_next;
    assign MU4 = MU4_next;

    // signal connection


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
            // If ALU_en is high, then we are in the multiply and accumulate state.
            counter_next = counter + 1;
            MU1_next = A_input*X_reg1 + MU1_r;
            MU2_next = A_input*X_reg2 + MU2_r;
            MU3_next = A_input*X_reg3 + MU3_r;
            MU4_next = A_input*X_reg4 + MU4_r;
            // If the counter reaches 8, we finish the sub matrix multiply and accumulate operation.
        end
        else begin
            // Finish the multiply and back to controller IDLE. Prepare to next input matrix.
            counter_next = 0;
            // Reset the MU registers.
            MU1_next = 18'b0; MU2_next = 18'b0; MU3_next = 18'b0; MU4_next = 18'b0; 
        end
    end 

endmodule
