module WB
#(parameter DATA_WIDTH = 32)
(input [DATA_WIDTH-1:0] i_ALU_Data,
 input [DATA_WIDTH-1:0] i_Mem_Data,
 input i_ctrl_MemToReg,
 input i_ctrl_RegWrite,
 input [4:0] i_Rd,
 output reg [DATA_WIDTH-1:0] o_WriteData,
 output reg o_ctrl_RegWrite,
 output reg [4:0] o_Rd
 );
 always@(*) begin
	o_WriteData = (i_ctrl_MemToReg)?i_Mem_Data:i_ALU_Data;
	o_Rd = i_Rd;
	o_ctrl_RegWrite = i_ctrl_RegWrite;
 end
endmodule 