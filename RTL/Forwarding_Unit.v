module Forwarding_Unit
(input [4:0] i_Rs1,
 input [4:0] i_Rs2,
 input [4:0] i_MEM_Rd,
 input       i_ctrl_MEM_RegWrite,
 input [4:0] i_WB_Rd,
 input       i_ctrl_WB_RegWrite,
 output reg [1:0] o_ctrl_ForwardA,
 output reg [1:0] o_ctrl_ForwardB
 );
 
 always@(*) begin
	if (i_ctrl_MEM_RegWrite && (i_MEM_Rd != 0) && (i_MEM_Rd == i_Rs1)) begin
		o_ctrl_ForwardA = 2'b10;
	end else if (i_ctrl_WB_RegWrite && (i_WB_Rd != 0) && (i_WB_Rd == i_Rs1)) begin
		o_ctrl_ForwardA = 2'b11;
	end else begin
		o_ctrl_ForwardA = 2'b00;
	end
	
	if (i_ctrl_MEM_RegWrite && (i_MEM_Rd != 0) && (i_MEM_Rd == i_Rs2)) begin
		o_ctrl_ForwardB = 2'b10;
	end else if (i_ctrl_WB_RegWrite && (i_WB_Rd != 0) && (i_WB_Rd == i_Rs2)) begin
		o_ctrl_ForwardB = 2'b11;
	end else begin
		o_ctrl_ForwardB = 2'b00;
	end
 end
 
endmodule 