module ID
#(parameter DATA_WIDTH = 32)
(input clk, n_rst,
 input [DATA_WIDTH-1:0] i_Inst,
 input [DATA_WIDTH-1:0] i_PC,
 input [DATA_WIDTH-1:0] i_WB_WriteData,
 input [DATA_WIDTH-1:0] i_MEM_WriteData,
 input i_ctrl_MEM_MemRead,
 input i_ctrl_MEM_RegWrite,
 input [4:0] i_MEM_Rd,
 input i_ctrl_WB_RegWrite,
 input [4:0] i_WB_Rd,
 input i_ctrl_EX_MemRead,
 input i_ctrl_EX_RegWrite, //////
 input [4:0] i_EX_Rd,
 input i_ctrl_EX_Br_taken,
 input i_ctrl_is_C_inst,
 input i_ctrl_EX_Busy,
 output reg o_ctrl_PC_Write,
 output reg o_ctrl_IFID_Write,
 output reg o_ctrl_IDEX_Write,
 output reg o_ctrl_EXMEM_Write,
 output reg o_ctrl_MEMWB_Write,
 output reg o_ctrl_MemRead,
 output reg o_ctrl_MemWrite,
 output reg o_ctrl_RegWrite,
 output reg o_ctrl_MemToReg,
 output reg o_ctrl_LUI,
 output reg o_ctrl_AUIPC,
 output reg o_ctrl_Imme,
 output reg o_ctrl_LT,
 output reg o_ctrl_LTU,
 output reg o_ctrl_EQ,
 output reg o_ctrl_kill,
 output reg o_ctrl_Jump,
 output reg o_ctrl_is_C_inst,
 output reg [5:0] o_ctrl_Br_Mask,
 output reg [1:0] o_ctrl_ALUop,
 output reg [2:0] o_ctrl_Mem_Mode,
 output reg [4:0] o_Rs1,
 output reg [4:0] o_Rs2,
 output reg [4:0] o_Rd,
 output reg [2:0] o_Funct3,
 output reg [6:0] o_Funct7,
 output reg [DATA_WIDTH-1:0] o_PC_Jump,
 output reg [DATA_WIDTH-1:0] o_PC,
 output reg [DATA_WIDTH-1:0] o_Imme,
 output reg [DATA_WIDTH-1:0] o_Read1,
 output reg [DATA_WIDTH-1:0] o_Read2
 );
 // Instruction field
 wire [4:0] w_Rs1, w_Rs2, w_Rd;
 wire [31:7] w_Imme;
 wire [6:0] w_Opcode, w_Funct7;
 wire [2:0] w_Funct3;
 
 // Control signal
 wire w_ctrl_PC_Sel, w_ctrl_MemRead, w_ctrl_MemWrite, w_ctrl_RegWrite, w_ctrl_MemToReg, w_ctrl_LUI, w_ctrl_AUIPC, w_ctrl_Imme;
 wire [1:0] w_ctrl_ALUop, w_ctrl_ForwardA, w_ctrl_ForwardB;
 wire [7:0] w_ctrl_Br_Mask;
 wire [2:0] w_ctrl_Mem_Mode, w_ctrl_ImmSel;
 wire w_ctrl_PC_Write, w_ctrl_IFID_Write, w_ctrl_flush, w_ctrl_LT, w_ctrl_LTU, w_ctrl_EQ, w_ctrl_kill, w_ctrl_Jump, w_ctrl_Branch;
 wire w_ctrl_IDEX_Write, w_ctrl_EXMEM_Write, w_ctrl_MEMWB_Write;
 
 // Data signal
 wire [DATA_WIDTH-1:0] w_ImmeExtend, w_Read1, w_Read2, w_PC_Branch, w_Mux_JALR, w_PC_Jump;
 reg [DATA_WIDTH-1:0] r_ForwardA, r_ForwardB;

 

 
 assign w_Rs1 = i_Inst[19:15];
 assign w_Rs2 = i_Inst[24:20];
 assign w_Rd = i_Inst[11:7];
 assign w_Imme = i_Inst[31:7];
 assign w_Opcode = i_Inst[6:0];
 assign w_Funct7 = i_Inst[31:25];
 assign w_Funct3 = i_Inst[14:12];
 
 assign w_ctrl_Jump = (|w_ctrl_Br_Mask[7:6]) & ~i_ctrl_EX_Br_taken;
 assign w_ctrl_Branch = |w_ctrl_Br_Mask[5:0];
 assign w_Mux_JALR = (w_ctrl_Br_Mask[6])?r_ForwardA:i_PC;
 assign w_PC_Jump = w_ImmeExtend + w_Mux_JALR;
 
 //assign w_PC_Branch =
 always@(*) begin
	case(w_ctrl_ForwardA)
		2'b00: r_ForwardA = w_Read1;
		2'b10: r_ForwardA = i_MEM_WriteData;
		2'b11: r_ForwardA = i_WB_WriteData;
		default: r_ForwardA = 32'dx;
	endcase
	
	case(w_ctrl_ForwardB)
		2'b00: r_ForwardB = w_Read2;
		2'b10: r_ForwardB = i_MEM_WriteData;
		2'b11: r_ForwardB = i_WB_WriteData;
		default: r_ForwardB = 32'dx;
	endcase
 end
 
 // Controller
 Controller Ctrler (.i_Opcode(w_Opcode),
						  .i_Funct3(w_Funct3),
						  .o_ctrl_Mem_Mode(w_ctrl_Mem_Mode),
						  .o_ctrl_MemRead(w_ctrl_MemRead),
						  .o_ctrl_MemWrite(w_ctrl_MemWrite),
						  .o_ctrl_RegWrite(w_ctrl_RegWrite),
						  .o_ctrl_MemToReg(w_ctrl_MemToReg),
						  .o_ctrl_ImmSel(w_ctrl_ImmSel),
						  .o_ctrl_Br_Mask(w_ctrl_Br_Mask),
						  .o_ctrl_ALUop(w_ctrl_ALUop),
						  .o_ctrl_LUI(w_ctrl_LUI),
						  .o_ctrl_AUIPC(w_ctrl_AUIPC),
						  .o_ctrl_Imme(w_ctrl_Imme)
						  );
 // ImmGen
 ImmGen immgen1(.i_Imme(w_Imme),
					 .i_ctrl_ImmSel(w_ctrl_ImmSel),
					 .i_Funct7(w_Funct7[5]),
					 .o_Imme(w_ImmeExtend)
					 );
					 
 // RegisterFile
 RegisterFile RegFile1(.clk(clk),
							  .n_rst(n_rst),
							  .i_rs1(w_Rs1),
							  .i_rs2(w_Rs2),
							  .i_rd(i_WB_Rd),
							  .i_WriteData(i_WB_WriteData),
							  .i_ctrl_RegWrite(i_ctrl_WB_RegWrite),
							  .o_Read1(w_Read1),
							  .o_Read2(w_Read2)
							  );

 // Hazard Detection Unit
 Hazard_Detection HazardDetection1 (.i_rs1(w_Rs1),
												.i_rs2(w_Rs2),
												.i_ctrl_EX_MemRead(i_ctrl_EX_MemRead),
												.i_ctrl_MEM_MemRead(i_ctrl_MEM_MemRead),
												.i_EX_rd(i_EX_Rd),
												.i_MEM_rd(i_MEM_Rd),
												.i_ctrl_EX_Br_taken(i_ctrl_EX_Br_taken),
												.i_ctrl_Jump(w_ctrl_Jump),
												.i_ctrl_Branch(w_ctrl_Branch),
												.i_ctrl_JALR(w_ctrl_Br_Mask[6]),
												.i_ctrl_EX_RegWrite(i_ctrl_EX_RegWrite),
												.i_ctrl_EX_Busy(i_ctrl_EX_Busy),
												.o_ctrl_PC_Write(w_ctrl_PC_Write),
												.o_ctrl_IFID_Write(w_ctrl_IFID_Write),
												.o_ctrl_flush(w_ctrl_flush),
												.o_ctrl_kill(w_ctrl_kill),
												.o_ctrl_IDEX_Write(w_ctrl_IDEX_Write),
												.o_ctrl_EXMEM_Write(w_ctrl_EXMEM_Write),
												.o_ctrl_MEMWB_Write(w_ctrl_MEMWB_Write)
												);
								
 // Forwarding Unit
 Forwarding_Unit FU1 (.i_Rs1(w_Rs1),
							 .i_Rs2(w_Rs2),
							 .i_MEM_Rd(i_MEM_Rd),
							 .i_ctrl_MEM_RegWrite(i_ctrl_MEM_RegWrite),
							 .i_WB_Rd(i_WB_Rd),
							 .i_ctrl_WB_RegWrite(i_ctrl_WB_RegWrite),
							 .o_ctrl_ForwardA(w_ctrl_ForwardA),
							 .o_ctrl_ForwardB(w_ctrl_ForwardB)
							 );
							 
 // Branch Comp
 Br_Comp BrComp1 (.i_Read1(r_ForwardA),
						.i_Read2(r_ForwardB),
						.o_ctrl_LT(w_ctrl_LT),
						.o_ctrl_LTU(w_ctrl_LTU),
						.o_ctrl_EQ(w_ctrl_EQ)
						);
						
 always@(*) begin
	if(w_ctrl_flush) begin
		o_ctrl_Br_Mask = {6'b0};
		o_ctrl_ALUop = 2'b00;
		o_ctrl_LUI = 1'b0;
		o_ctrl_AUIPC = 1'b0;
		o_ctrl_Mem_Mode = 3'b000;
		o_ctrl_MemRead = 1'b0;
		o_ctrl_MemWrite = 1'b0;
		o_ctrl_MemToReg = 1'b0;
		o_ctrl_RegWrite = w_ctrl_Jump;
		o_ctrl_Imme = 1'b0;
		o_ctrl_LT = 1'b0;
		o_ctrl_LTU = 1'b0;
		o_ctrl_EQ = 1'b0;
		o_Funct3 = 3'b000;
		o_Funct7 = 7'b0000000;
	end else begin
		o_ctrl_Br_Mask = w_ctrl_Br_Mask[5:0];
		o_ctrl_ALUop = w_ctrl_ALUop;
		o_ctrl_LUI = w_ctrl_LUI;
		o_ctrl_AUIPC = w_ctrl_AUIPC;
		o_ctrl_Mem_Mode = w_ctrl_Mem_Mode;
		o_ctrl_MemRead = w_ctrl_MemRead;
		o_ctrl_MemWrite = w_ctrl_MemWrite;
		o_ctrl_MemToReg = w_ctrl_MemToReg;
		o_ctrl_RegWrite = w_ctrl_RegWrite;
		o_ctrl_Imme = w_ctrl_Imme;
		o_ctrl_LT = w_ctrl_LT;
		o_ctrl_LTU = w_ctrl_LTU;
		o_ctrl_EQ = w_ctrl_EQ;
		o_Funct3 = w_Funct3;
		o_Funct7 = w_Funct7;
	end
	
	o_Read1 = r_ForwardA;
	o_Read2 = r_ForwardB;
	o_Rs1 = w_Rs1;
	o_Rs2 = w_Rs2;
	o_Rd = w_Rd;
	o_Imme = w_ImmeExtend;
	o_PC = i_PC;
	o_ctrl_PC_Write = w_ctrl_PC_Write;
	o_ctrl_IFID_Write = w_ctrl_IFID_Write;
	o_ctrl_IDEX_Write = w_ctrl_IDEX_Write;
	o_ctrl_EXMEM_Write = w_ctrl_EXMEM_Write;
	o_ctrl_MEMWB_Write = w_ctrl_MEMWB_Write;
	o_PC_Jump = w_PC_Jump;
	o_ctrl_kill = w_ctrl_kill;
	o_ctrl_Jump = w_ctrl_Jump;
	o_ctrl_is_C_inst = i_ctrl_is_C_inst;
 end
endmodule