module A_rom_test(
    input  clk,
    input  rst,

    input  [3:0]  rom_addr,
    output [13:0] A_input
);

    localparam NUM_KEYS = 32;   //total data num    
    localparam INPUT_FILE = "E:/course/master/ICP/Matrix/verilog/user/data/A_input.txt";

    reg [6:0] memory [0:NUM_KEYS-1]; // 7 bit memory with 32 entries
    integer memory_index = 0;

    reg [13:0] rom_out;
    reg [13:0] rom_out_next;
    assign A_input = rom_out;

initial begin
    $readmemb(INPUT_FILE, memory);
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        rom_out <= 14'b0;
    end
    else begin
       rom_out <= rom_out_next;
    end
end

always @(*) begin
    rom_out_next ={memory[{rom_addr,1'b0}],memory[{rom_addr,1'b1}]};//store two column number in one word
end

endmodule