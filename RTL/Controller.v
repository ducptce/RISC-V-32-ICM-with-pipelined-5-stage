`include "def.v"
module Controller 
(input [6:0] i_Opcode,
 input [2:0] i_Funct3,
 output reg [2:0] o_ctrl_Mem_Mode,
 output reg o_ctrl_MemRead,
 output reg o_ctrl_MemWrite,
 output reg o_ctrl_RegWrite,
 output reg o_ctrl_MemToReg,
 output reg [2:0] o_ctrl_ImmSel,
 output reg [7:0] o_ctrl_Br_Mask,
 output reg [1:0] o_ctrl_ALUop,
 output reg o_ctrl_LUI,
 output reg o_ctrl_AUIPC,
 output reg o_ctrl_Imme
 );
 always@(*) begin
	o_ctrl_Mem_Mode = i_Funct3;
	o_ctrl_MemRead = (i_Opcode == `LOAD)?1'b1:1'b0;
	o_ctrl_MemWrite = (i_Opcode == `STORE)?1'b1:1'b0;
	o_ctrl_RegWrite = (i_Opcode == `BRANCH || i_Opcode == `STORE)?1'b0:1'b1;
	o_ctrl_MemToReg = (i_Opcode == `LOAD)?1'b1:1'b0;
	o_ctrl_ImmSel = (i_Opcode == `LOAD || i_Opcode == `JALR || i_Opcode == `OP_IMM)?3'b000:(i_Opcode == `STORE)?3'b001:(i_Opcode == `BRANCH)?3'b010:(i_Opcode == `AUIPC || i_Opcode == `LUI)?3'b011:(i_Opcode == `JAL)?3'b100:3'bxxx;
	o_ctrl_Br_Mask[7] = (i_Opcode == `JAL)?1'b1:1'b0;
	o_ctrl_Br_Mask[6] = (i_Opcode == `JALR)?1'b1:1'b0;
	o_ctrl_Br_Mask[5] = (i_Opcode == `BRANCH && i_Funct3 == `FUNCT3_BGEU)?1'b1:1'b0;
	o_ctrl_Br_Mask[4] = (i_Opcode == `BRANCH && i_Funct3 == `FUNCT3_BLTU)?1'b1:1'b0;
	o_ctrl_Br_Mask[3] = (i_Opcode == `BRANCH && i_Funct3 == `FUNCT3_BGE)?1'b1:1'b0;
	o_ctrl_Br_Mask[2] = (i_Opcode == `BRANCH && i_Funct3 == `FUNCT3_BNE)?1'b1:1'b0;
	o_ctrl_Br_Mask[1] = (i_Opcode == `BRANCH && i_Funct3 == `FUNCT3_BLT)?1'b1:1'b0;
	o_ctrl_Br_Mask[0] = (i_Opcode == `BRANCH && i_Funct3 == `FUNCT3_BEQ)?1'b1:1'b0;
	o_ctrl_ALUop = (i_Opcode == `LOAD || i_Opcode == `STORE || i_Opcode == `BRANCH || i_Opcode == `AUIPC || i_Opcode == `JALR)?2'b00:(i_Opcode == `OP)?2'b01:(i_Opcode == `OP_IMM)?2'b10:2'bxx;
	o_ctrl_LUI = (i_Opcode == `LUI)?1'b1:1'b0;
	o_ctrl_AUIPC = (i_Opcode == `AUIPC)?1'b1:1'b0;
	o_ctrl_Imme = (i_Opcode == `OP)?1'b0:1'b1;
 end
 
 
endmodule 