module sram_mem(
    input         clk,
    input         rst,  
    input         we_n,
    input         read_n,
    input  [7:0]  w_addr,  
    input  [7:0]  r_addr,
    input  [31:0] write_data,

    output reg ry,
    output reg [8:0] data_out
);
    wire        ry_sram;   
    wire        cs_n;
    wire [7:0]  addr;
    wire [31:0] sram_data;
    assign addr = we_n ? r_addr:w_addr;
    assign cs_n = (read_n&&we_n);


    localparam IDLE      = 2'd0;
    localparam WAIT_DATA = 2'd1;
    localparam READ_DATA = 2'd2;
    localparam OUT_NEXT  = 2'd3;

    reg [1:0] state, next_state;
    reg [8:0] data_buffer;  // data from SRAM
    reg [8:0] data_buffer_next;

    // update state and data
    always @(posedge clk) begin
        if (!rst) begin
            state     <= IDLE;
            data_buffer  <= 32'b0;
        end 
        else begin
            state        <= next_state;
            data_buffer  <= data_buffer_next;
        end
    end
    //FSM
    always @(*) begin
        case(state)
            IDLE:      next_state = read_n||(!ry_sram) ? IDLE:WAIT_DATA;
            WAIT_DATA: next_state = READ_DATA;
            READ_DATA: next_state = OUT_NEXT;
            OUT_NEXT:  next_state = IDLE;
            default:   next_state = IDLE;
        endcase
    end

    always @(*) begin
        ry = 1'b0;
        data_out = 9'd0;
        data_buffer_next = data_buffer;
        case(state)
            IDLE: begin
                ry = 1'b0;
                data_out = 9'd0;
            end
            WAIT_DATA: begin
                ry = 1'b0;
                data_out = 9'd0;
            end
            READ_DATA: begin
                ry = 1'b1;
                data_out = sram_data[8:0];
                data_buffer_next =sram_data[17:9];
            end
            OUT_NEXT: begin
                ry = 1'b1;
                data_out = data_buffer;
            end
            default: begin
                ry = 1'b0;
                data_out = 9'd0;
            end
        endcase
    end

wire LOW = 1'b0;
    ST_SPHDL_160x32m8_L u_sram (
    .CK         (clk        ),
    .CSN        (cs_n       ),     
    .WEN        (we_n       ),       
    .A          (addr       ),
    .D          (write_data ), 
    .Q          (sram_data  ),
    .RY         (ry_sram    ),
    .TBYPASS    (LOW        )
    );

endmodule
