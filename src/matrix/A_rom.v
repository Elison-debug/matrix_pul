module A_rom(
    input  clk,
    input  rst,

    input  [3:0]  rom_addr,
    output [7:0]  A_input
);

    parameter num_1_1 = 8'b11100011;
    parameter num_1_2 = 8'b11000000;
    parameter num_1_3 = 8'b01110110;

    parameter num_2_1 = 8'b11011010;
    parameter num_2_2 = 8'b01110000;
    parameter num_2_3 = 8'b11001000;

    parameter num_3_1 = 8'b00100000;
    parameter num_3_2 = 8'b00100000;
    parameter num_3_3 = 8'b01001011;

    reg [7:0] rom_out;
    reg [7:0] rom_out_next;
    assign A_input = rom_out;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        rom_out <= 8'b0;
    end
    else begin
       rom_out <= rom_out_next;
    end
end

always @(*) begin
    case (rom_addr)
        //column 1
        4'b0000 : rom_out_next = num_1_1 ;
        4'b0001 : rom_out_next = num_1_2 ;
        4'b0010 : rom_out_next = num_1_3 ;
        //column 2
        4'b0011 : rom_out_next = num_2_1 ;
        4'b0100 : rom_out_next = num_2_2 ;
        4'b0101 : rom_out_next = num_2_3 ;
        //column 3
        4'b0110 : rom_out_next = num_3_1 ;
        4'b0111 : rom_out_next = num_3_2 ;
        4'b1000 : rom_out_next = num_3_3 ;
        default : rom_out_next = 8'b0;
    endcase
end

endmodule
