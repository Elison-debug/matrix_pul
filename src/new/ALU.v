module ALU(
    input  clk,
    input  rst,
    input        ALU_en,  
    input [7:0]  A_input,
    input [55:0] X_reg,    // Input 7*8bit elemments 

    output [19:0] MU1,     // output result for each mul-sum product seperately
    output [19:0] MU2,
    output [19:0] MU3,
    output [19:0] MU4,   
    output [19:0] MU5,
    output [19:0] MU6,
    output [19:0] MU7,
    output [3:0 ] addr_offset,    
    output web 
);  
    // Reg for the mul op counter. 
    reg   [3:0] counter, counter_next;
    assign addr_offset = counter_next;

    //finish and web signal
    assign web  = (counter == 3'b1000);

    // MU Reg
    reg [19:0]  MU1_r;
    reg [19:0]  MU2_r;
    reg [19:0]  MU3_r;
    reg [19:0]  MU4_r;
    reg [19:0]  MU5_r;
    reg [19:0]  MU6_r;
    reg [19:0]  MU7_r;
    reg [19:0]  MU1_next,MU2_next,MU3_next,MU4_next,MU5_next,MU6_next,MU7_next;
    

    assign MU1 = MU1_next;
    assign MU2 = MU2_next;
    assign MU3 = MU3_next;
    assign MU4 = MU4_next;
    assign MU5 = MU5_next;
    assign MU6 = MU6_next;
    assign MU7 = MU7_next;
    //split X_reg into 7 8-bit wire.

    wire [7:0] X_reg1 = X_reg[55:48];
    wire [7:0] X_reg2 = X_reg[47:40];
    wire [7:0] X_reg3 = X_reg[39:32];
    wire [7:0] X_reg4 = X_reg[31:24];
    wire [7:0] X_reg5 = X_reg[23:16];
    wire [7:0] X_reg6 = X_reg[15: 8];
    wire [7:0] X_reg7 = X_reg[7 : 0];   

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            MU1_r <= 0; MU2_r <= 0; MU3_r <= 0; MU4_r <= 0;
            MU5_r <= 0; MU6_r <= 0; MU7_r <= 0;
            counter <= 0; 
        end
        else begin
                counter <= counter_next;
                MU1_r <= MU1_next; 
                MU2_r <= MU2_next; 
                MU3_r <= MU3_next; 
                MU4_r <= MU4_next;
                MU5_r <= MU5_next;
                MU6_r <= MU6_next;
                MU7_r <= MU7_next;
        end
    end

    // ALU
    always @(*) begin
        counter_next = counter;
        if (ALU_en) begin
            // If ALU_en is high, then we are in the multiply and accumulate state.
            counter_next = counter + 1;
            MU1_next = A_input*X_reg1 + MU1_r;
            MU2_next = A_input*X_reg2 + MU2_r;
            MU3_next = A_input*X_reg3 + MU3_r;
            MU4_next = A_input*X_reg4 + MU4_r;
            MU5_next = A_input*X_reg5 + MU5_r;
            MU6_next = A_input*X_reg6 + MU6_r;
            MU7_next = A_input*X_reg7 + MU7_r;
            // If the counter reaches 8, we finish the accumulate operation.
        end
        else begin
            // Finish the multiply and back to controller IDLE. Prepare to next input matrix.
            counter_next = 0;
            // Reset the MU registers.
            MU1_next = 18'b0; MU2_next = 18'b0; MU3_next = 18'b0; MU4_next = 18'b0; 
        end
    end 

endmodule
