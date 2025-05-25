module X_buffer(
    input  clk,
    input  rst,
    input  valid_input,
    input  load_en,
    input  X_shift,
    input  [32:0] X_load,    //iniput data
    input  [2 :0] col_counter,
    
    output [7:0] X_reg1,
    output [7:0] X_reg2,
    output [7:0] X_reg3,
    output load_done
);
    //counter
    reg [2:0] count;
    reg [2:0] count_next;

    // four X buffer
    reg [87:0] s_reg1;
    reg [87:0] s_reg2;
    reg [87:0] s_reg3;

    reg [87:0] s_reg1_next;
    reg [87:0] s_reg2_next;
    reg [87:0] s_reg3_next;
    
    // X buffer output
    assign X_reg1 = s_reg1[87:24];
    assign X_reg2 = s_reg2[87:24];
    assign X_reg3 = s_reg3[87:24];

    //last column of a row flag
    wire   last_col;
    assign last_col = (col_counter == 2'b11) ? 1'b1 : 1'b0;

    //load done flag
    assign load_done = last_col ? (count == 3'b011) : (count == 3'b111);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        s_reg1      <= 80'b0;
        s_reg2      <= 80'b0;
        s_reg3      <= 80'b0;
        count       <= 3'b0;
    end
    else begin
        //update counter
        count       <= count_next;
        s_reg1      <= s_reg1_next;
        s_reg2      <= s_reg2_next;
        s_reg3      <= s_reg3_next;
    end
end

//shift buffer
always @(*) begin
    count_next     = count;
    s_reg1_next    = s_reg1;
    s_reg2_next    = s_reg2;
    s_reg3_next    = s_reg3;

    if(load_en && valid_input)begin
        case({col_counter,count[1:0]})
            2'b00 : begin 
                    case(count)
                        //load first column
                        3'b000 : begin s_reg1_next = {56'b0 , X_load} count_next = count + 5'd1 ;  end
                        3'b001 : begin s_reg2_next = {56'b0 , X_load} count_next = count + 5'd1 ;  end 
                        3'b010 : begin s_reg3_next = {56'b0 , X_load} count_next = count + 5'd1 ;  end 
                        //load second column
                        3'b100 : begin s_reg1_next = {s_reg1[39:0] , X_load,24'b0} count_next = count + 5'd2 ;  end 
                        3'b101 : begin s_reg2_next = {s_reg1[39:0] , X_load,24'b0} count_next = count + 5'd1 ;  end 
                        3'b110 : begin s_reg3_next = {s_reg1[39:0] , X_load,24'b0} count_next = count + 5'd2 ;  end 
                        default : count_next  = count;
                    endcase
                 end 
            2'b01 : begin
                    case(count)
                        //load first column
                        3'b000 : begin s_reg1_next = {s_reg1[39:0] , X_load} count_next = count + 5'd1 ;  end
                        3'b001 : begin s_reg2_next = {s_reg1[39:0] , X_load} count_next = count + 5'd1 ;  end 
                        3'b010 : begin s_reg3_next = {s_reg1[39:0] , X_load} count_next = count + 5'd1 ;  end 
                        //load second column
                        3'b100 : begin s_reg1_next = {s_reg1[39:0] , X_load} count_next = count + 5'd2 ;  end 
                        3'b101 : begin s_reg2_next = {s_reg1[39:0] , X_load} count_next = count + 5'd1 ;  end 
                        3'b110 : begin s_reg3_next = {s_reg1[39:0] , X_load} count_next = count + 5'd2 ;  end 
                        default : count_next  = count;
                    endcase
                 end 
            2'b10 : begin
                    case(count)
                        //load first column
                        3'b000 : begin s_reg1_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end
                        3'b001 : begin s_reg2_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end 
                        3'b010 : begin s_reg3_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end 
                        //load second column
                        3'b100 : begin s_reg1_next = {s_reg1[31:0] , X_load} count_next = count + 5'd2 ;  end 
                        3'b101 : begin s_reg2_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end 
                        3'b110 : begin s_reg3_next = {s_reg1[31:0] , X_load} count_next = count + 5'd2 ;  end 
                        default : count_next  = count;
                    endcase
                 end 
            2'b11 : begin
                    case(count)
                        //load first column
                        3'b000 : begin s_reg1_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end
                        3'b001 : begin s_reg2_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end 
                        3'b010 : begin s_reg3_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end 
                        //load second column
                        3'b100 : begin s_reg1_next = {s_reg1[31:0] , X_load} count_next = count + 5'd2 ;  end 
                        3'b101 : begin s_reg2_next = {s_reg1[31:0] , X_load} count_next = count + 5'd1 ;  end 
                        3'b110 : begin s_reg3_next = {s_reg1[31:0] , X_load} count_next = count + 5'd2 ;  end 
                        default : count_next  = count;
                    endcase
                 end 
            default : begin
                //default case, do nothing
                count_next = count;
            end
        endcase
    end else if(X_shift) begin
        s_reg1_next = {s_reg1[55:0] , s_reg1[63:56]};
        s_reg2_next = {s_reg2[55:0] , s_reg2[63:56]};
        s_reg3_next = {s_reg3[55:0] , s_reg3[63:56]};
        s_reg4_next = {s_reg4[55:0] , s_reg4[63:56]};
    end
end


endmodule