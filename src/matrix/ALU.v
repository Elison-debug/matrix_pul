module ALU(
    input  clk,
    input  rst,
    input        ALU_en,  
    input [7:0]  A_input,
    input [23:0] X_reg1,
    input [23:0] X_reg2,
    input [23:0] X_reg3,

    output [20:0] sum,     // output result for each mul-sum product seperately
    output reg web 
);  

    //finish and web signal
    wire web_next;
    assign web_next  = ALU_en; // web is high when ALU_en is high
    
    // MU Reg
    reg [16:0]  MU1_r;
    reg [16:0]  MU2_r;
    reg [16:0]  MU3_r;
    reg [16:0]  MU4_r;
    reg [16:0]  MU5_r;
    reg [16:0]  MU6_r;
    reg [16:0]  MU7_r;
    reg [16:0]  MU8_r;
    reg [16:0]  MU9_r;

    reg [19:0]  MU1_next,MU2_next,MU3_next,MU4_next;
    reg [19:0]  MU5_next,MU6_next,MU7_next,MU8_next,MU9_next;
    
    //adder trees
    wire [17:0] sum0 = MU1_r + MU2_r;
    wire [17:0] sum1 = MU3_r + MU4_r;
    wire [17:0] sum2 = MU5_r + MU6_r;
    wire [17:0] sum3 = MU7_r + MU8_r;

    wire [18:0] sum4 = sum0 + sum1;
    wire [18:0] sum5 = sum2 + sum3;

    wire [19:0] sum6 = sum4 + sum5;
    // Final sum
    assign sum  = sum6 + MU9_r;

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            MU1_r <= 0; MU2_r <= 0; MU3_r <= 0; MU4_r <= 0;
            MU5_r <= 0; MU6_r <= 0; MU7_r <= 0;
        end
        else begin
                MU1_r <= MU1_next; 
                MU2_r <= MU2_next; 
                MU3_r <= MU3_next; 
                MU4_r <= MU4_next;
                MU5_r <= MU5_next;
                MU6_r <= MU6_next;
                MU7_r <= MU7_next;
                MU8_r <= MU8_next;
                MU9_r <= MU9_next;
        end
    end

    // ALU
    always @(*) begin
        if (ALU_en) begin
            // If ALU_en is high, then we are in the multiply and accumulate state.
            MU1_next = A_input*X_reg1[23:16];
            MU2_next = A_input*X_reg1[15: 8];
            MU3_next = A_input*X_reg1[7 : 0];
            MU4_next = A_input*X_reg2[23:16];
            MU5_next = A_input*X_reg2[15: 8];
            MU6_next = A_input*X_reg2[7 : 0];
            MU7_next = A_input*X_reg3[23:16];
            MU8_next = A_input*X_reg3[15: 8];
            MU9_next = A_input*X_reg3[7 : 0];
        end
        else begin
            // Reset the MU registers.
            MU1_next = 18'b0; MU2_next = 18'b0; MU3_next = 18'b0; MU4_next = 18'b0;
            MU5_next = 18'b0; MU6_next = 18'b0; MU7_next = 18'b0;
            MU8_next = 18'b0; MU9_next = 18'b0;
        end
    end 

endmodule
