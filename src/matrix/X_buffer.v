module X_buffer(
    input  clk,
    input  rst,
    input  valid_input,
    input  load_en,
    input  rom_addr,
    input  [32:0] X_load,    //iniput data
    input  [2 :0] col_counter,
    
    output [7:0] X_reg1,
    output [7:0] X_reg2,
    output [7:0] X_reg3, 
    output [7:0] X_reg4, // output data
    output load_done
);
    //counter
    reg [2:0] count;
    reg [2:0] count_next;

    // four X buffer
    reg [71:0] s_reg1 [2:0];
    reg [71:0] s_reg1_next [2:0];

    
    // X buffer output
    assign X_reg1 = s_reg1 [0] [71:56];
    assign X_reg2 = s_reg1 [1] [71:56];
    assign X_reg3 = s_reg1 [2] [71:56];

    //last column of a row flag
    wire   first_col;
    assign first_col = (col_counter == 3'b000) ? 1'b1 : 1'b0;

    //load done flag
    assign load_done = first_col ? (count == 'b0) : (count == 3'b111);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        s_reg1[0]   <= 72'b0;
        s_reg1[1]   <= 72'b0;
        s_reg1[2]   <= 72'b0;
        count       <= 3'b0;
    end
    else begin
        //update counter
        count       <= count_next;
        s_reg1[0]   <= s_reg1_next[0];
        s_reg1[1]   <= s_reg1_next[1];
        s_reg1[2]   <= s_reg1_next[2];
    end
end

//shift buffer
always @(*) begin
    count_next     = count;
    s_reg1_next[0]    = s_reg1[0];
    s_reg1_next[1]    = s_reg1[1];
    s_reg1_next[2]    = s_reg1[2];
    //default case, do nothing
    if(load_en && valid_input)begin
        case(col_counter)
            3'b000 : begin 
                    s_reg1_next[0] = {8'b0,s_reg1[0][31:0] , X_load} ; 
                    count_next = count + 3'd1 ;  
                 end 
            3'b111 : begin
                    count_next = count;  
                 end
            default : begin
                    s_reg1_next[0] = {s_reg1[0][55:32] , X_load} ; 
                    //s_reg1_next[0][31:0] = X_load; 
                    count_next = count + 3'd1 ;  
            end
        endcase
    end else if(X_shift) begin
        s_reg1_next[0] = {s_reg1[0][63:24] , s_reg1[0][71:64]};
        s_reg1_next[1] = {s_reg1[0][63:24] , s_reg1[0][71:64]};
        s_reg1_next[2] = {s_reg1[0][63:24] , s_reg1[0][71:64]};
    end
end


endmodule