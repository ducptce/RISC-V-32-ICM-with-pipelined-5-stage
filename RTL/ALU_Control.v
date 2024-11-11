`include "def.v"
module ALU_Control
(input [1:0] i_ctrl_ALUop,
 input [2:0] i_Funct3,
 input [6:0] i_Funct7,
 output reg [3:0] o_ctrl_ALU_Sel,
 output reg o_ctrl_Unsigned,
 output reg o_ctrl_HSU,
 output reg o_ctrl_Start_Mul,
 output reg o_ctrl_Start_Div
 );	
 
 wire w_ADD, w_SUB, w_XOR, w_OR, w_AND, w_SLL, w_SRL, w_SRA, w_SLT, w_SLTU, w_MUL, w_MULH, w_MULHSU, w_MULHU, w_DIV, w_DIVU, w_REM, w_REMU;
 
 assign w_ADD = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_ADD && i_Funct3 == `FUNCT3_ADD) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_ADDI));
 assign w_SUB = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SUB && i_Funct3 == `FUNCT3_SUB);
 assign w_XOR = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_XOR && i_Funct3 == `FUNCT3_XOR) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_XORI));
 assign w_OR = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_OR && i_Funct3 == `FUNCT3_OR) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_ORI));
 assign w_AND = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_AND && i_Funct3 == `FUNCT3_AND) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_ANDI));
 assign w_SLL = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SLL && i_Funct3 == `FUNCT3_SLL) || (i_ctrl_ALUop == 2'b10 && i_Funct7 == `FUNCT7_SLLI && i_Funct3 == `FUNCT3_SLLI));
 assign w_SRL = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SRL && i_Funct3 == `FUNCT3_SRL) || (i_ctrl_ALUop == 2'b10 && i_Funct7 == `FUNCT7_SRLI && i_Funct3 == `FUNCT3_SRLI));
 assign w_SRA = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SRA && i_Funct3 == `FUNCT3_SRA) || (i_ctrl_ALUop == 2'b10 && i_Funct7 == `FUNCT7_SRAI && i_Funct3 == `FUNCT3_SRAI));
 assign w_SLT = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SLT && i_Funct3 == `FUNCT3_SLT) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_SLTI));
 assign w_SLTU = ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SLTU && i_Funct3 == `FUNCT3_SLTU) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_SLTIU));
 assign w_MUL = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_MUL && i_Funct3 == `FUNCT3_MUL);
 assign w_MULH = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_MULH && i_Funct3 == `FUNCT3_MULH);
 assign w_MULHSU = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_MULHSU && i_Funct3 == `FUNCT3_MULHSU);
 assign w_MULHU = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_MULHU && i_Funct3 == `FUNCT3_MULHU);
 assign w_DIV = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_DIV && i_Funct3 == `FUNCT3_DIV);
 assign w_DIVU = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_DIVU && i_Funct3 == `FUNCT3_DIVU);
 assign w_REM = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_REM && i_Funct3 == `FUNCT3_REM);
 assign w_REMU = (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_REMU && i_Funct3 == `FUNCT3_REMU);
 
 always@(*) begin
	if(i_ctrl_ALUop == 2'b00 || w_ADD) begin
		o_ctrl_ALU_Sel = 4'b0000;
	end else if (w_SUB) begin
		o_ctrl_ALU_Sel = 4'b0001;		
	end else if (w_XOR) begin
		o_ctrl_ALU_Sel = 4'b0010;
	end else if (w_OR) begin
		o_ctrl_ALU_Sel = 4'b0011;
	end else if (w_AND) begin 
		o_ctrl_ALU_Sel = 4'b0100;
	end else if (w_SLL) begin
		o_ctrl_ALU_Sel = 4'b0101;
	end else if (w_SRL) begin
		o_ctrl_ALU_Sel = 4'b0110;
	end else if (w_SRA) begin
		o_ctrl_ALU_Sel = 4'b0111;
	end else if (w_SLT) begin
		o_ctrl_ALU_Sel = 4'b1000;
	end else if (w_SLTU) begin
		o_ctrl_ALU_Sel = 4'b1001;
	end else if (w_MUL) begin 
		o_ctrl_ALU_Sel = 4'b1010;
	end else if(w_MULH) begin
		o_ctrl_ALU_Sel = 4'b1011;
	end else if(w_MULHSU) begin
		o_ctrl_ALU_Sel = 4'b1011;
	end else if(w_MULHU) begin
		o_ctrl_ALU_Sel = 4'b1011;
	end else if(w_DIV) begin
		o_ctrl_ALU_Sel = 4'b1100;
	end else if(w_DIVU) begin
		o_ctrl_ALU_Sel = 4'b1100;
	end else if(w_REM) begin
		o_ctrl_ALU_Sel = 4'b1101;
	end else if(w_REMU) begin
		o_ctrl_ALU_Sel = 4'b1101;
	end else begin
		o_ctrl_ALU_Sel = 4'bxxxx;
	end
	
	o_ctrl_Unsigned = w_MULHU | w_DIVU | w_REMU;
	o_ctrl_HSU = w_MULHSU | w_MULHU;
	o_ctrl_Start_Mul = w_MUL | w_MULH | w_MULHSU | w_MULHU;
	o_ctrl_Start_Div = w_DIV | w_DIVU | w_REM | w_REMU;
 end
 /*always@(*) begin 
	if(i_ctrl_ALUop == 2'b00 || (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_ADD && i_Funct3 == `FUNCT3_ADD) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_ADDI)) begin
		o_ctrl_ALU_Sel = 4'b0000;
	end else if (i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SUB && i_Funct3 == `FUNCT3_SUB) begin
		o_ctrl_ALU_Sel = 4'b0001;		
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_XOR && i_Funct3 == `FUNCT3_XOR) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_XORI)) begin
		o_ctrl_ALU_Sel = 4'b0010;
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_OR && i_Funct3 == `FUNCT3_OR) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_ORI)) begin
		o_ctrl_ALU_Sel = 4'b0011;
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_AND && i_Funct3 == `FUNCT3_AND) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_ANDI)) begin 
		o_ctrl_ALU_Sel = 4'b0100;
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SLL && i_Funct3 == `FUNCT3_SLL) || (i_ctrl_ALUop == 2'b10 && i_Funct7 == `FUNCT7_SLLI && i_Funct3 == `FUNCT3_SLLI)) begin
		o_ctrl_ALU_Sel = 4'b0101;
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SRL && i_Funct3 == `FUNCT3_SRL) || (i_ctrl_ALUop == 2'b10 && i_Funct7 == `FUNCT7_SRLI && i_Funct3 == `FUNCT3_SRLI)) begin
		o_ctrl_ALU_Sel = 4'b0110;
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SRA && i_Funct3 == `FUNCT3_SRA) || (i_ctrl_ALUop == 2'b10 && i_Funct7 == `FUNCT7_SRAI && i_Funct3 == `FUNCT3_SRAI)) begin
		o_ctrl_ALU_Sel = 4'b0111;
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SLT && i_Funct3 == `FUNCT3_SLT) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_SLTI)) begin
		o_ctrl_ALU_Sel = 4'b1000;
	end else if ((i_ctrl_ALUop == 2'b01 && i_Funct7 == `FUNCT7_SLTU && i_Funct3 == `FUNCT3_SLTU) || (i_ctrl_ALUop == 2'b10 && i_Funct3 == `FUNCT3_SLTIU)) begin
		o_ctrl_ALU_Sel = 4'b1001;
	end else begin
		o_ctrl_ALU_Sel = 4'bxxxx;
	end
 end*/
 
endmodule
