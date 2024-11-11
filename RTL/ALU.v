module ALU
#(parameter DATA_WIDTH = 32)
(input clk,
 input n_rst,
 input [3:0] i_ctrl_ALU_Sel,
 input [DATA_WIDTH-1:0] i_A,
 input [DATA_WIDTH-1:0] i_B,
 input i_ctrl_Unsigned,
 input i_ctrl_HSU,
 input i_ctrl_Start_Mul,
 input i_ctrl_Start_Div,
 output reg [DATA_WIDTH-1:0] o_ALU_Result,
 output reg o_ctrl_Done
 ); 
reg signed [DATA_WIDTH-1:0] r_sign_A, r_sign_B;
reg [DATA_WIDTH-1:0] r_mux1, r_mux2;
wire [2*DATA_WIDTH-1:0] w_Product;
wire [DATA_WIDTH-1:0] w_Remainder, w_Quotient;
wire w_ctrl_Done_Mul, w_ctrl_Done_Div;

 Multiplier mul1 (.clk(clk),
					   .n_rst(n_rst),
					   .i_ctrl_Start(i_ctrl_Start_Mul),
					   .i_ctrl_Unsigned(i_ctrl_Unsigned),
					   .i_ctrl_HSU(i_ctrl_HSU),
					   .i_A(i_A),
					   .i_B(i_B),
					   .o_Product(w_Product),
					   .o_ctrl_Done(w_ctrl_Done_Mul)
					   );
						
 Divider div1 (.clk(clk),
				   .n_rst(n_rst),
				   .i_ctrl_Start(i_ctrl_Start_Div),
				   .i_ctrl_Unsigned(i_ctrl_Unsigned),
				   .i_A(i_A),
				   .i_B(i_B),
				   .o_Remainder(w_Remainder),
				   .o_Quotient(w_Quotient),
				   .o_ctrl_Done(w_ctrl_Done_Div)
				   );
					  
always@(*) begin
	r_sign_A = i_A;
	r_sign_B = i_B;
	case(i_ctrl_ALU_Sel) 
		4'b0000: o_ALU_Result = i_A + i_B;												//ADD
		4'b0001: o_ALU_Result = i_A - i_B;												//SUB
		4'b0010: o_ALU_Result = i_A ^ i_B;												//XOR
		4'b0011: o_ALU_Result = i_A | i_B;												//OR
		4'b0100: o_ALU_Result = i_A & i_B;												//AND
		4'b0101: o_ALU_Result = i_A << i_B;												//SHIFT LEFT LOGIC
		4'b0110: o_ALU_Result = i_A >> i_B;												//SHIFT RIGHT LOGIC
		4'b0111: o_ALU_Result = r_sign_A >>> i_B;										//SHIFT RIGHT ARITHMETIC																																//SET ON LESS THAN UNSIGNED
		4'b1000: o_ALU_Result = (r_sign_A < r_sign_B)?1:0;							//SET ON LESS THAN																															//SET ON LESS THAN
		4'b1001: o_ALU_Result = (i_A < i_B)?1:0;										//SET ON LESS THAN UNSIGNED
		4'b1010: o_ALU_Result = w_Product[DATA_WIDTH-1:0];							//MUL LOW
		4'b1011: o_ALU_Result = w_Product[2*DATA_WIDTH-1:DATA_WIDTH];			//MUL HIGH
		4'b1100: o_ALU_Result = w_Quotient;												//DIV
		4'b1101: o_ALU_Result = w_Remainder;											//REM
		//4'b1110: o_ALU_Result = 32'dx;
		//4'b1111: o_ALU_Result = 32'dx;
		default: o_ALU_Result = 32'dx;
	endcase
	
	o_ctrl_Done = w_ctrl_Done_Mul & w_ctrl_Done_Div;
end
endmodule