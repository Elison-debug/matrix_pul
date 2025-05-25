module sram_mem#(
    parameter APB_ADDR_WIDTH = 13  //acc sram are 8KB by default
)(
    input                           clk,
    input                           rst,  
    input                          we_n,
    input                        read_n,
    input  [APB_ADDR_WIDTH-1:0]  w_addr,  
    input  [APB_ADDR_WIDTH-1:0]  r_addr,
    input  [31:0] write_data,

    output ry,
    output [31:0] data_out
);
    wire        cs_n;
    wire [7:0]  addr;
    assign addr = we_n ? r_addr:w_addr;
    assign cs_n = (read_n && we_n);

    wire LOW = 1'b0;
    
    ST_SPHDL_160x32m8_L u_sram (
    .CK         (clk        ),
    .CSN        (cs_n       ),     
    .WEN        (we_n       ),       
    .A          (addr       ),
    .D          (write_data ), 
    .Q          (data_out   ),
    .RY         (ry         ),
    .TBYPASS    (LOW        )
    );

endmodule
