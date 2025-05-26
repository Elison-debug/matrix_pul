module X_buffer#(
    parameter APB_ADDR_WIDTH = 13  //APB slaves are 4KB by default
)(
    input  clk,
    input  rst,
    input  valid_input,
    input  load_en,
    input  X_shift, 
    input  [32:0] X_load,    //input data
    input  [3 :0] shift_count,
    input  [7 :0] acc_counter,
    output [7:0] col_counter,
    output [55:0] X_reg,
    output load_done
);
    //counter
    reg [2:0] count;
    reg [2:0] count_next;

    // four X buffer
    reg [71:0] s_reg [2:0];
    reg [71:0] s_reg_next [2:0];

    //last column of a row flag
    wire   first_col;
    assign first_col = (col_counter == 3'b000) ? 1'b1 : 1'b0;

    //load done flag
    assign load_done = count == 3'b111;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        s_reg[0]   <= 72'b0;
        s_reg[1]   <= 72'b0;
        s_reg[2]   <= 72'b0;
        count       <= 3'b0;
    end
    else begin
        //update counter
        count      <= count_next;
        s_reg[0]   <= s_reg_next[0];
        s_reg[1]   <= s_reg_next[1];
        s_reg[2]   <= s_reg_next[2];
    end
end

//buffer load
always @(*) begin
    count_next     = count;
    s_reg_next[0]    = s_reg[0];
    s_reg_next[1]    = s_reg[1];
    s_reg_next[2]    = s_reg[2];
    //default case, do nothing
    if(load_en && valid_input)begin
        case(col_counter)
            3'b000 : begin 
                    s_reg_next[0] = {8'b0,s_reg[0][31:0] , X_load} ; 
                    count_next = count + 3'd1 ;  
                 end 
            3'b111 : begin
                    count_next = count;  
                 end
            default : begin
                    s_reg_next[0] = {s_reg[0][55:32] , X_load} ; 
                    //s_reg_next[0][31:0] = X_load; 
                    count_next = count + 3'd1 ;  
            end
        endcase
    end 
    else if(X_shift) begin
        s_reg_next[0] = {s_reg[0][63:0] , s_reg[0][71:64]};
        s_reg_next[1] = {s_reg[1][63:0] , s_reg[1][71:64]};
        s_reg_next[2] = {s_reg[2][63:0] , s_reg[2][71:64]};
    end
end

//shift buffer
always @(*) begin
    case(shift_count)
        4'd0,4'd1,4'd2 : begin 
            X_reg = s_reg [0][71:16];
        end 
        4'd3,4'd4,4'd5 : begin 
            X_reg = s_reg [1][71:16]; 
        end
        4'd6,4'd7,4'd8 : begin 
            X_reg = s_reg [2][71:16]; 
        end
        default : begin
                X_reg = 32'b0; 
        end
    endcase
end
endmodule