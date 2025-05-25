module X_buffer(
    input  clk,
    input  rst,
    input  valid_input,
    input  input_load_en,
    input  [7:0] X_load,//iniput data
    //input  ram_en,
    input  X_shift,
    
    output [7:0] X_reg1,
    output [7:0] X_reg2,
    output [7:0] X_reg3,
    output [7:0] X_reg4,
    output xload_done
);
    //counter
    reg [4:0] count;
    reg [4:0] count_next;

    // four X buffer
    reg [63:0] s_reg1;
    reg [63:0] s_reg2;
    reg [63:0] s_reg3;
    reg [63:0] s_reg4;

    reg [63:0] s_reg1_next;
    reg [63:0] s_reg2_next;
    reg [63:0] s_reg3_next;
    reg [63:0] s_reg4_next;
    
    // X buffer output
    assign X_reg1 = s_reg1[63:56];
    assign X_reg2 = s_reg2[63:56];
    assign X_reg3 = s_reg3[63:56];
    assign X_reg4 = s_reg4[63:56];

    //load done flag
    assign xload_done = (count == 5'b11111);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        s_reg1      <= 64'b0;
        s_reg2      <= 64'b0;
        s_reg3      <= 64'b0;
        s_reg4      <= 64'b0;
        count       <= 5'b0;
    end
    else begin
        //update counter
        count       <= count_next;
        s_reg1      <= s_reg1_next;
        s_reg2      <= s_reg2_next;
        s_reg3      <= s_reg3_next;
        s_reg4      <= s_reg4_next;
    end
end

//shift buffer
always @(*) begin
    count_next     = count;
    s_reg1_next    = s_reg1;
    s_reg2_next    = s_reg2;
    s_reg3_next    = s_reg3;
    s_reg4_next    = s_reg4;

    if(input_load_en && valid_input)begin
        case(count[1:0])
        2'b00 : s_reg1_next = {s_reg1[55:0] , X_load} ;
        2'b01 : s_reg2_next = {s_reg2[55:0] , X_load} ;
        2'b10 : s_reg3_next = {s_reg3[55:0] , X_load} ;
        2'b11 : s_reg4_next = {s_reg4[55:0] , X_load} ;
        //default
        endcase
        count_next = count + 5'b1;
    end
    else if(X_shift) begin
        s_reg1_next = {s_reg1[55:0] , s_reg1[63:56]};
        s_reg2_next = {s_reg2[55:0] , s_reg2[63:56]};
        s_reg3_next = {s_reg3[55:0] , s_reg3[63:56]};
        s_reg4_next = {s_reg4[55:0] , s_reg4[63:56]};
    end
end


endmodule