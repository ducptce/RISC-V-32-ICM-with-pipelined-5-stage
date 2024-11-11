module ImmGen 
#(parameter WIDTH = 32)
(input wire [2:0] i_ctrl_ImmSel,
 input wire i_Funct7,
 input wire [31:7] i_Imme,
 output reg [31:0] o_Imme
 );
always @(*) begin
	case(i_ctrl_ImmSel)
		// I_Immediate
	  3'b000: o_Imme = (i_Funct7)?{{22{i_Imme[31]}}, i_Imme[29:20]}:{{21{i_Imme[31]}}, i_Imme[30:20]};
	   // S_Immediate
	  3'b001: o_Imme = {{21{i_Imme[31]}}, i_Imme[30:25], i_Imme[11:8], i_Imme[7]};
	   // B_Immediate
	  3'b010: o_Imme = {{20{i_Imme[31]}}, i_Imme[7], i_Imme[30:25], i_Imme[11:8], 1'b0};
		// U_Immediate
	  3'b011: o_Imme = {i_Imme[31:12], 12'h0};
	   // J_Immediate
	  3'b100: o_Imme = {{12{i_Imme[31]}}, i_Imme[19:12], i_Imme[20], i_Imme[30:21], 1'b0};
	  default: o_Imme = 32'h0;
	 endcase
end
endmodule
