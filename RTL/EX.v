module EX
#(parameter DATA_WIDTH = 32)
(input clk,
 input n_rst,
 input [DATA_WIDTH-1:0] i_Read1,
 input [DATA_WIDTH-1:0] i_Read2,
 input [DATA_WIDTH-1:0] i_PC,
 input [DATA_WIDTH-1:0] i_Imme,
 input [DATA_WIDTH-1:0] i_MEM_WriteData,
 input [DATA_WIDTH-1:0] i_WB_WriteData,
 input [4:0] i_Rs1,
 input [4:0] i_Rs2,
 input [4:0] i_Rd,
 input [4:0] i_MEM_Rd,
 input [2:0] i_Funct3,
 input [6:0] i_Funct7,
 input i_ctrl_MEM_RegWrite,
 input i_ctrl_MemRead,
 input i_ctrl_MemWrite,
 input i_ctrl_RegWrite,
 input i_ctrl_MemToReg,
 input i_ctrl_LUI,
 input i_ctrl_AUIPC,
 input i_ctrl_Imme,
 input i_ctrl_LT,
 input i_ctrl_LTU,
 input i_ctrl_EQ,
 input i_ctrl_Jump,
 input i_ctrl_WB_RegWrite,
 input i_ctrl_is_C_inst,
 input [1:0] i_ctrl_ALUop,
 input [2:0] i_ctrl_Mem_Mode,
 input [5:0] i_ctrl_Br_Mask,
 input [4:0] i_WB_Rd,
 output reg [DATA_WIDTH-1:0] o_nPC,
 output reg [DATA_WIDTH-1:0] o_Imme,
 output reg o_ctrl_LUI,
 output reg o_ctrl_Br_taken,
 output reg [DATA_WIDTH-1:0] o_WriteData,
 output reg [DATA_WIDTH-1:0] o_PC_Branch,
 output reg [DATA_WIDTH-1:0] o_Mem_WriteData,
 output reg [4:0] o_Rd,
 output reg o_ctrl_MemRead,
 output reg o_ctrl_MemWrite,
 output reg o_ctrl_RegWrite,
 output reg o_ctrl_MemToReg,
 output reg o_ctrl_Jump,
 output reg [2:0] o_ctrl_Mem_Mode,
 output reg o_ctrl_Busy
 );
 
 wire w_ctrl_Br_taken, w_ctrl_BEQ, w_ctrl_BLT, w_ctrl_BNE, w_ctrl_BGE, w_ctrl_BLTU, w_ctrl_BGEU;
 wire w_ctrl_ALU_Done, w_ctrl_Start_Mul, w_ctrl_Start_Div, w_ctrl_Unsigned, w_ctrl_HSU;
 wire [1:0] w_ctrl_ForwardA, w_ctrl_ForwardB;
 wire [3:0] w_ctrl_ALU_Sel;
 wire [DATA_WIDTH-1:0] w_ALUresult, w_nPC;
 reg [DATA_WIDTH-1:0] r_ForwardA, r_ForwardB, r_ALU_OperandA, r_ALU_OperandB;
 
 assign w_nPC = i_PC + ((i_ctrl_is_C_inst)?2:4);
 assign w_ctrl_BEQ = i_ctrl_EQ & i_ctrl_Br_Mask[0];
 assign w_ctrl_BLT = i_ctrl_LT & i_ctrl_Br_Mask[1];
 assign w_ctrl_BNE = ~i_ctrl_EQ & i_ctrl_Br_Mask[2];
 assign w_ctrl_BGE = ~i_ctrl_LT & i_ctrl_Br_Mask[3];
 assign w_ctrl_BLTU = i_ctrl_LTU & i_ctrl_Br_Mask[4];
 assign w_ctrl_BGEU = ~i_ctrl_LTU & i_ctrl_Br_Mask[5];
 assign w_ctrl_Br_taken = w_ctrl_BEQ | w_ctrl_BLT | w_ctrl_BNE | w_ctrl_BGE | w_ctrl_BLTU | w_ctrl_BGEU;
 
 always@(*) begin
	case(w_ctrl_ForwardA)
		2'b00: r_ForwardA = i_Read1;
		2'b10: r_ForwardA = i_MEM_WriteData;
		2'b11: r_ForwardA = i_WB_WriteData;
		default: r_ForwardA = 32'dx;
	endcase
	
	case(w_ctrl_ForwardB)
		2'b00: r_ForwardB = i_Read2;
		2'b10: r_ForwardB = i_MEM_WriteData;
		2'b11: r_ForwardB = i_WB_WriteData;
		default: r_ForwardB = 32'dx;
	endcase
	
	case(i_ctrl_AUIPC)
		1'b0: r_ALU_OperandA = r_ForwardA;
		1'b1: r_ALU_OperandA = i_PC;
		default: r_ALU_OperandA = 32'dx;
	endcase
	
	case(i_ctrl_Imme)
		1'b0: r_ALU_OperandB = r_ForwardB;
		1'b1: r_ALU_OperandB = i_Imme;
		default: r_ALU_OperandB = 32'dx;
	endcase
 end
 
 ALU_Control ALUctrl1 (.i_ctrl_ALUop(i_ctrl_ALUop),
							  .i_Funct3(i_Funct3),
							  .i_Funct7(i_Funct7),
							  .o_ctrl_ALU_Sel(w_ctrl_ALU_Sel),
							  .o_ctrl_Unsigned(w_ctrl_Unsigned),
							  .o_ctrl_HSU(w_ctrl_HSU),
							  .o_ctrl_Start_Mul(w_ctrl_Start_Mul),
							  .o_ctrl_Start_Div(w_ctrl_Start_Div)
							  );
						
 ALU alu1 (.clk(clk),
			  .n_rst(n_rst),
			  .i_ctrl_ALU_Sel(w_ctrl_ALU_Sel),
			  .i_A(r_ALU_OperandA),
			  .i_B(r_ALU_OperandB),
			  .i_ctrl_Unsigned(w_ctrl_Unsigned),
			  .i_ctrl_HSU(w_ctrl_HSU),
			  .i_ctrl_Start_Mul(w_ctrl_Start_Mul),
			  .i_ctrl_Start_Div(w_ctrl_Start_Div),
			  .o_ALU_Result(w_ALUresult),
			  .o_ctrl_Done(w_ctrl_ALU_Done)
			  );
 
 Forwarding_Unit FU1 (.i_Rs1(i_Rs1),
							 .i_Rs2(i_Rs2),
							 .i_MEM_Rd(i_MEM_Rd),
							 .i_ctrl_MEM_RegWrite(i_ctrl_MEM_RegWrite),
							 .i_WB_Rd(i_WB_Rd),
							 .i_ctrl_WB_RegWrite(i_ctrl_WB_RegWrite),
							 .o_ctrl_ForwardA(w_ctrl_ForwardA),
							 .o_ctrl_ForwardB(w_ctrl_ForwardB)
							 );
 
 always@(*) begin
	o_nPC = w_nPC;
	o_Imme = i_Imme;
	o_ctrl_LUI = i_ctrl_LUI;
	o_ctrl_Br_taken = w_ctrl_Br_taken;
	o_WriteData = w_ALUresult;
	o_PC_Branch = i_PC + i_Imme;
	o_Rd = i_Rd;
	o_ctrl_MemRead = i_ctrl_MemRead;
	o_ctrl_MemWrite = i_ctrl_MemWrite;
	o_ctrl_RegWrite = i_ctrl_RegWrite;
	o_ctrl_MemToReg = i_ctrl_MemToReg;
	o_ctrl_Mem_Mode = i_ctrl_Mem_Mode;
	o_Mem_WriteData = r_ForwardB;
	o_ctrl_Jump = i_ctrl_Jump;
	o_ctrl_Busy = ~w_ctrl_ALU_Done;
 end
endmodule
