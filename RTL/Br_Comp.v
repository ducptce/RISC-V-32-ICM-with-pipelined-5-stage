module Br_Comp 
#(parameter DATA_WIDTH = 32)
(input [DATA_WIDTH-1:0] i_Read1,
 input [DATA_WIDTH-1:0] i_Read2,
 output reg o_ctrl_LT,
 output reg o_ctrl_LTU,
 output reg o_ctrl_EQ
 );
 wire w_ctrl_EQ, w_ctrl_LTU, w_ctrl_LT;
 reg signed [DATA_WIDTH-1:0] r_sign_Read1, r_sign_Read2;
 
 
 assign w_ctrl_LTU = (i_Read1 < i_Read2)?1'b1:1'b0;
 assign w_ctrl_LT = (r_sign_Read1 < r_sign_Read2)?1'b1:1'b0;
 assign w_ctrl_EQ = (i_Read1 == i_Read2)?1'b1:1'b0;
 
 always@(*) begin
   r_sign_Read1 = i_Read1;
	r_sign_Read2 = i_Read2;
	o_ctrl_LTU = w_ctrl_LTU;
	o_ctrl_LT = w_ctrl_LT;
	o_ctrl_EQ = w_ctrl_EQ; 
 end

endmodule