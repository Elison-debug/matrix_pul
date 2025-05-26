module X_buffer#(
    parameter APB_ADDR_WIDTH = 13  //APB slaves are 4KB by default
)(
    input  clk,
    input  rst,
    input  ALU_en, //En shift buffer
    input  load_en,
    input  valid_input,
    input  [32:0] X_load,    //input data
    input  [1 :0] row_counter,
    output [55:0] X_reg,
    output load_done
);
    //counter
    reg [2:0] count;
    reg [2:0] count_next;

    // four X buffer
    reg [243:0] s_reg [3:0];
    reg [243:0] s_reg_next [3:0];

    //last column of a row flag
    wire   first_col;
    assign first_col = (col_counter == 3'b000) ? 1'b1 : 1'b0;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        s_reg[0]   <= 72'b0;
        s_reg[1]   <= 72'b0;
        s_reg[2]   <= 72'b0;
        s_reg[3]   <= 72'b0;
        count       <= 3'b0;
    end
    else begin
        //update counter
        count      <= count_next;
        s_reg[0]   <= s_reg_next[0];
        s_reg[1]   <= s_reg_next[1];
        s_reg[2]   <= s_reg_next[2];
        s_reg[3]   <= s_reg_next[3];
    end
end

//buffer load
always @(*) begin
    count_next       = count;
    s_reg_next[0]    = s_reg[0];
    s_reg_next[1]    = s_reg[1];
    s_reg_next[2]    = s_reg[2];
    s_reg_next[3]    = s_reg[3];
    if(load_en && valid_input)begin
        case(row_counter)
            2'b00 : begin 
                    s_reg_next[0] = {s_reg[0][207:0] , X_load} ; 
                 end 
            2'b01 : begin 
                    s_reg_next[1] = {s_reg[1][207:0] , X_load} ; 
                 end
            2'b10 : begin 
                    s_reg_next[2] = {s_reg[2][207:0] , X_load} ; 
                 end
            2'b11 : begin 
                    s_reg_next[3] = {s_reg[3][207:0] , X_load} ; 
                 end
            default : begin
                    count_next = count;  
            end
        endcase
        count_next = count +1'b1;  
    end 
    else if(ALU_en) begin
        s_reg_next[row_counter]       = {s_reg[0][215:0] , s_reg[0][243:216]};
        s_reg_next[row_counter+2'b1]  = {s_reg[1][215:0] , s_reg[1][243:216]};
        s_reg_next[row_counter+2'b11] = {s_reg[2][215:0] , s_reg[2][243:216]};
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