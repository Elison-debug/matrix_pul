`timescale 1ns / 1ns
module A_buffer(
    input  clk,
    input  rst,
    input  load_A_en,
    input  valid_input,
    input  [31:0]PWDATA,

    output reg load_A_done, 
    output [71:0]  A_input
);
    //counter
    reg [1:0] count;
    reg [1:0] count_next;

    reg [71:0] rom_out;
    reg [71:0] rom_out_next;
    assign A_input = rom_out;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        count   <= 2'b0;
        rom_out <= 8'b0;
    end
    else begin
        count   <= count_next;
        rom_out <= rom_out_next;
    end
end

always @(*) begin
    count_next = count;
    rom_out_next = rom_out;
    load_A_done = 1'b0;
    if(load_A_en && valid_input)begin
        case (count)
            2'b00,2'b01: begin
                rom_out_next = {rom_out_next[39:0], PWDATA};
                count_next = count + 1'b1; // Increment count
            end
            2'b10: begin
                rom_out_next = {rom_out_next[63:0], PWDATA[7:0]};
                count_next = 2'b00; // Reset count after loading all data
                load_A_done = 1'b1; // Indicate that loading is done
            end
            default: begin
                count_next = count;
            end
        endcase
    end
end

endmodule
