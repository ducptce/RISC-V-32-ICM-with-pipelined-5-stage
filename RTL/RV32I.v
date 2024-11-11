module RV32I
#(parameter DATA_WIDTH = 32)
(input clk,
 input n_rst,
 output reg [DATA_WIDTH-1:0] o_WB_DataOut
 );

 // IF signal 
 wire [DATA_WIDTH-1:0] w_IF_PC, w_IF_Inst;
 // IFID reg
 reg  [DATA_WIDTH-1:0] r_IFID_PC, r_IFID_Inst;

 wire  [DATA_WIDTH-1:0] w_IFID_PC, w_IFID_Inst;
 // ID signal
 wire w_ID_ctrl_PC_Write, w_ID_ctrl_IFID_Write, w_ID_ctrl_IFID_rst_sync, w_ID_ctrl_MemRead, w_ID_ctrl_MemWrite, w_ID_ctrl_Imme;
 wire w_ID_ctrl_RegWrite, w_ID_ctrl_MemToReg, w_ID_ctrl_LUI, w_ID_ctrl_AUIPC, w_ID_ctrl_is_ID_Branch, w_ID_ctrl_PC_Sel; 
 wire [1:0] w_ID_ctrl_ALUop;
 wire [2:0] w_ID_ctrl_Mem_Mode, w_ID_Funct3;
 wire [4:0] w_ID_Rs1, w_ID_Rs2, w_ID_Rd;
 wire [6:0] w_ID_ctrl_Br_Mask, w_ID_Funct7;
 wire [DATA_WIDTH-1:0] w_ID_Read1, w_ID_Read2, w_ID_PC, w_ID_Imme, w_ID_PC_Branch; 
 // IDEX reg
 reg r_IDEX_ctrl_MemRead, r_IDEX_ctrl_MemWrite, r_IDEX_ctrl_Imme, r_IDEX_ctrl_RegWrite, r_IDEX_ctrl_MemToReg;
 reg r_IDEX_ctrl_LUI, r_IDEX_ctrl_AUIPC; 
 reg [1:0] r_IDEX_ctrl_ALUop;
 reg [2:0] r_IDEX_ctrl_Mem_Mode, r_IDEX_Funct3;
 reg [4:0] r_IDEX_Rs1, r_IDEX_Rs2, r_IDEX_Rd;
 reg [6:0] r_IDEX_ctrl_Br_Mask, r_IDEX_Funct7;
 reg [DATA_WIDTH-1:0] r_IDEX_Read1, r_IDEX_Read2, r_IDEX_PC, r_IDEX_Imme;

 wire w_IDEX_ctrl_MemRead, w_IDEX_ctrl_MemWrite, w_IDEX_ctrl_Imme, w_IDEX_ctrl_RegWrite, w_IDEX_ctrl_MemToReg;
 wire w_IDEX_ctrl_LUI, w_IDEX_ctrl_AUIPC; 
 wire [1:0] w_IDEX_ctrl_ALUop;
 wire [2:0] w_IDEX_ctrl_Mem_Mode, w_IDEX_Funct3;
 wire [4:0] w_IDEX_Rs1, w_IDEX_Rs2, w_IDEX_Rd;
 wire [6:0] w_IDEX_ctrl_Br_Mask, w_IDEX_Funct7;
 wire [DATA_WIDTH-1:0] w_IDEX_Read1, w_IDEX_Read2, w_IDEX_PC, w_IDEX_Imme, w_IDEX_PC_Branch;
 // EX signal
 wire w_EX_ctrl_LUI, w_EX_ctrl_isJump, w_EX_ctrl_Br_taken, w_EX_ctrl_MemRead, w_EX_ctrl_MemWrite, w_EX_ctrl_RegWrite, w_EX_ctrl_MemToReg;
 wire [2:0] w_EX_ctrl_Mem_Mode;
 wire [4:0] w_EX_Rd; 
 wire [DATA_WIDTH-1:0] w_EX_nPC, w_EX_Imme, w_EX_WriteData, w_EX_PC_Branch, w_EX_Mem_WriteData;

 // EXMEM reg
 reg r_EXMEM_ctrl_MemRead, r_EXMEM_ctrl_MemWrite, r_EXMEM_ctrl_RegWrite, r_EXMEM_ctrl_MemToReg, r_EXMEM_ctrl_LUI, r_EXMEM_ctrl_isJump;
 reg [2:0] r_EXMEM_ctrl_Mem_Mode;
 reg [4:0] r_EXMEM_Rd; 
 reg [DATA_WIDTH-1:0] r_EXMEM_WriteData, r_EXMEM_Mem_WriteData, r_EXMEM_nPC, r_EXMEM_Imme;

 wire w_EXMEM_ctrl_MemRead, w_EXMEM_ctrl_MemWrite, w_EXMEM_ctrl_RegWrite, w_EXMEM_ctrl_MemToReg;
 wire [2:0] w_EXMEM_ctrl_Mem_Mode;
 wire [4:0] w_EXMEM_Rd; 
 wire [DATA_WIDTH-1:0] w_EXMEM_WriteData, w_EXMEM_PC_Branch, w_EXMEM_Mem_WriteData;
 
 // MEM signal
 wire w_MEM_ctrl_RegWrite, w_MEM_ctrl_MemToReg;
 wire [4:0] w_MEM_Rd;
 wire [DATA_WIDTH-1:0] w_MEM_MemOut, w_MEM_DataOut;
 // MEMWB reg 
 reg r_MEMWB_ctrl_RegWrite, r_MEMWB_ctrl_MemToReg;
 reg [4:0] r_MEMWB_Rd;
 reg [DATA_WIDTH-1:0] r_MEMWB_MemOut, r_MEMWB_DataOut;
 
 wire w_MEMWB_ctrl_RegWrite, w_MEMWB_ctrl_MemToReg;
 wire [4:0] w_MEMWB_Rd;
 wire [DATA_WIDTH-1:0] w_MEMWB_MemOut, w_MEMWB_DataOut;
 // WB signal
 wire w_WB_ctrl_RegWrite;
 wire [4:0] w_WB_Rd;
 wire [DATA_WIDTH-1:0] w_WB_WriteData;
 
 always@(posedge clk or negedge n_rst) begin
    if(!n_rst) begin
        // IFID
        r_IFID_Inst <= 32'd0;
        r_IFID_PC <= 32'd0;

        // IDEX
        r_IDEX_ctrl_MemRead <= 1'b0; 
        r_IDEX_ctrl_MemWrite <= 1'b0; 
        r_IDEX_ctrl_Imme <= 1'b0;
        r_IDEX_ctrl_RegWrite <= 1'b0; 
        r_IDEX_ctrl_MemToReg <= 1'b0;
        r_IDEX_ctrl_LUI <= 1'b0;
        r_IDEX_ctrl_AUIPC <= 1'b0;
        r_IDEX_ctrl_ALUop <= 2'b00;
        r_IDEX_ctrl_Mem_Mode <= 3'b000;
        r_IDEX_Funct3 <= 3'b000;
        r_IDEX_Rs1 <= 5'b00000;
        r_IDEX_Rs2 <= 5'b00000;
        r_IDEX_Rd <= 5'b00000;
        r_IDEX_ctrl_Br_Mask <= 7'b0000000;
        r_IDEX_Funct7 <= 7'b0000000;
        r_IDEX_Read1 <= 32'd0;
        r_IDEX_Read2 <= 32'd0;
        r_IDEX_PC <= 32'd0;
        r_IDEX_Imme <= 32'd0;

        // EXMEM
        r_EXMEM_ctrl_Mem_Mode <= 3'b000;
        r_EXMEM_ctrl_MemRead <= 1'b0;
        r_EXMEM_ctrl_MemToReg <= 1'b0;
        r_EXMEM_ctrl_MemWrite <= 1'b0;
        r_EXMEM_ctrl_RegWrite <= 1'b0;
        r_EXMEM_Mem_WriteData <= 32'd0;
        r_EXMEM_Rd <= 5'b00000;
        r_EXMEM_WriteData <= 32'd0;
    
        // MEMWB
        r_MEMWB_ctrl_MemToReg <= 1'b0;
        r_MEMWB_ctrl_RegWrite <= 1'b0;
        r_MEMWB_DataOut <= 32'd0;
        r_MEMWB_MemOut <= 32'd0;
        r_MEMWB_Rd <= 5'b00000;
    end else begin
        // IFID
        if (w_EX_ctrl_Br_taken) begin
            r_IFID_Inst <= 32'd0;
            r_IFID_PC <= 32'd0;
        end else if (w_ID_ctrl_IFID_Write) begin
            r_IFID_Inst <= w_IF_Inst;
            r_IFID_PC <= w_IF_PC;
        end

        // IDEX
        r_IDEX_ctrl_MemRead <= w_ID_ctrl_MemRead; 
        r_IDEX_ctrl_MemWrite <= w_ID_ctrl_MemWrite; 
        r_IDEX_ctrl_Imme <= w_ID_ctrl_Imme;
        r_IDEX_ctrl_RegWrite <= w_ID_ctrl_RegWrite; 
        r_IDEX_ctrl_MemToReg <= w_ID_ctrl_MemToReg;
        r_IDEX_ctrl_LUI <= w_ID_ctrl_LUI;
        r_IDEX_ctrl_AUIPC <= w_ID_ctrl_AUIPC;
        r_IDEX_ctrl_ALUop <= w_ID_ctrl_ALUop;
        r_IDEX_ctrl_Mem_Mode <= w_ID_ctrl_Mem_Mode;
        r_IDEX_Funct3 <= w_ID_Funct3;
        r_IDEX_Rs1 <= w_ID_Rs1;
        r_IDEX_Rs2 <= w_ID_Rs2;
        r_IDEX_Rd <= w_ID_Rd;
        r_IDEX_ctrl_Br_Mask <= w_ID_ctrl_Br_Mask;
        r_IDEX_Funct7 <= w_ID_Funct7;
        r_IDEX_Read1 <= w_ID_Read1;
        r_IDEX_Read2 <= w_ID_Read2;
        r_IDEX_PC <= w_ID_PC;
        r_IDEX_Imme <= w_ID_Imme;

        // EXMEM
        r_EXMEM_ctrl_Mem_Mode <= w_EX_ctrl_Mem_Mode;
        r_EXMEM_ctrl_MemRead <= w_EX_ctrl_MemRead;
        r_EXMEM_ctrl_MemToReg <= w_EX_ctrl_MemToReg;
        r_EXMEM_ctrl_MemWrite <= w_EX_ctrl_MemWrite;
        r_EXMEM_ctrl_RegWrite <= w_EX_ctrl_RegWrite;
        r_EXMEM_Mem_WriteData <= w_EX_Mem_WriteData;
        r_EXMEM_Rd <= w_EX_Rd;
        r_EXMEM_WriteData <= w_EX_WriteData;
		  r_EXMEM_nPC <= w_EX_nPC;
		  r_EXMEM_Imme <= w_EX_Imme;
		  r_EXMEM_ctrl_LUI <= w_EX_ctrl_LUI;
		  r_EXMEM_ctrl_isJump <= w_EX_ctrl_isJump;
        // MEMWB
        r_MEMWB_ctrl_MemToReg <= w_MEM_ctrl_MemToReg;
        r_MEMWB_ctrl_RegWrite <= w_MEM_ctrl_RegWrite;
        r_MEMWB_DataOut <= w_MEM_DataOut;
        r_MEMWB_MemOut <= w_MEM_MemOut;
        r_MEMWB_Rd <= w_MEM_Rd;
    end
 end

 IF IF1 (.clk(clk),
         .n_rst(n_rst),
         .i_ctrl_PC_Write(w_ID_ctrl_PC_Write),
			.i_ctrl_PC_Sel(w_EX_ctrl_Br_taken),
         .i_EX_br_addr(w_EX_PC_Branch),
         .o_PC(w_IF_PC),
         .o_Inst(w_IF_Inst)
         );
 
 ID ID1 (.clk(clk),
         .n_rst(n_rst),
         .i_Inst(r_IFID_Inst),
         .i_PC(r_IFID_PC),
         .i_WB_WriteData(w_WB_WriteData),
         .i_ctrl_WB_RegWrite(w_WB_ctrl_RegWrite),
         .i_WB_rd(w_WB_Rd),
         .i_ctrl_EX_MemRead(r_IDEX_ctrl_MemRead),
         .i_EX_rd(r_IDEX_Rd),
			.i_ctrl_EX_Br_taken(w_EX_ctrl_Br_taken),
         .o_ctrl_PC_Write(w_ID_ctrl_PC_Write),
         .o_ctrl_IFID_Write(w_ID_ctrl_IFID_Write),
         .o_Read1(w_ID_Read1),
         .o_Read2(w_ID_Read2),
         .o_Rs1(w_ID_Rs1),
         .o_Rs2(w_ID_Rs2),
         .o_Rd(w_ID_Rd),
         .o_PC(w_ID_PC),
         .o_Imme(w_ID_Imme),
         .o_ctrl_MemRead(w_ID_ctrl_MemRead),
         .o_ctrl_MemWrite(w_ID_ctrl_MemWrite),
         .o_ctrl_RegWrite(w_ID_ctrl_RegWrite),
         .o_ctrl_MemToReg(w_ID_ctrl_MemToReg),
         .o_ctrl_Br_Mask(w_ID_ctrl_Br_Mask),
         .o_ctrl_ALUop(w_ID_ctrl_ALUop),
         .o_ctrl_Mem_Mode(w_ID_ctrl_Mem_Mode),
         .o_ctrl_LUI(w_ID_ctrl_LUI),
         .o_ctrl_AUIPC(w_ID_ctrl_AUIPC),
         .o_ctrl_Imme(w_ID_ctrl_Imme),
         .o_Funct3(w_ID_Funct3),
         .o_Funct7(w_ID_Funct7)
         );
 
 EX EX1 (.i_Read1(r_IDEX_Read1),
         .i_Read2(r_IDEX_Read2),
         .i_PC(r_IDEX_PC),
         .i_Imme(r_IDEX_Imme),
         .i_MEM_WriteData(r_EXMEM_WriteData),
         .i_WB_WriteData(w_WB_WriteData),
         .i_Rs1(r_IDEX_Rs1),
         .i_Rs2(r_IDEX_Rs2),
         .i_Rd(r_IDEX_Rd),
         .i_MEM_Rd(r_EXMEM_Rd),
         .i_WB_Rd(r_MEMWB_Rd),
         .i_Funct3(r_IDEX_Funct3),
         .i_Funct7(r_IDEX_Funct7),
         .i_ctrl_MEM_RegWrite(r_EXMEM_ctrl_RegWrite),
         .i_ctrl_WB_RegWrite(r_MEMWB_ctrl_RegWrite),
         .i_ctrl_MemRead(r_IDEX_ctrl_MemRead),
         .i_ctrl_MemWrite(r_IDEX_ctrl_MemWrite),
         .i_ctrl_RegWrite(r_IDEX_ctrl_RegWrite),
         .i_ctrl_MemToReg(r_IDEX_ctrl_MemToReg),
         .i_ctrl_LUI(r_IDEX_ctrl_LUI),
         .i_ctrl_AUIPC(r_IDEX_ctrl_AUIPC),
         .i_ctrl_Imme(r_IDEX_ctrl_Imme),
         .i_ctrl_ALUop(r_IDEX_ctrl_ALUop),
         .i_ctrl_Mem_Mode(r_IDEX_ctrl_Mem_Mode),
         .i_ctrl_Br_Mask(r_IDEX_ctrl_Br_Mask),
			.o_nPC(w_EX_nPC),
			.o_Imme(w_EX_Imme),
			.o_ctrl_LUI(w_EX_ctrl_LUI),
			.o_ctrl_isJump(w_EX_ctrl_isJump),
         .o_ctrl_Br_taken(w_EX_ctrl_Br_taken),
         .o_WriteData(w_EX_WriteData),
         .o_PC_Branch(w_EX_PC_Branch),
         .o_Mem_WriteData(w_EX_Mem_WriteData),
         .o_Rd(w_EX_Rd),
         .o_ctrl_MemRead(w_EX_ctrl_MemRead),
         .o_ctrl_MemWrite(w_EX_ctrl_MemWrite),
         .o_ctrl_RegWrite(w_EX_ctrl_RegWrite),
         .o_ctrl_MemToReg(w_EX_ctrl_MemToReg),
         .o_ctrl_Mem_Mode(w_EX_ctrl_Mem_Mode)
         );
 
 MEM MEM1 (.clk(clk),
           .n_rst(n_rst),
           .i_ctrl_MemRead(r_EXMEM_ctrl_MemRead),
           .i_ctrl_MemWrite(r_EXMEM_ctrl_MemWrite),
           .i_ctrl_RegWrite(r_EXMEM_ctrl_RegWrite),
           .i_ctrl_MemToReg(r_EXMEM_ctrl_MemToReg),
           .i_ctrl_Mem_Mode(r_EXMEM_ctrl_Mem_Mode),
           .i_Rd(r_EXMEM_Rd),
           .i_Addr(r_EXMEM_WriteData),
           .i_WriteData(r_EXMEM_Mem_WriteData),
			  .i_nPC(r_EXMEM_nPC),
			  .i_Imme(r_EXMEM_Imme),
			  .i_ctrl_LUI(r_EXMEM_ctrl_LUI),
			  .i_ctrl_isJump(r_EXMEM_ctrl_isJump),
           .o_Rd(w_MEM_Rd),
           .o_MemOut(w_MEM_MemOut),
           .o_DataOut(w_MEM_DataOut),
           .o_ctrl_RegWrite(w_MEM_ctrl_RegWrite),
           .o_ctrl_MemToReg(w_MEM_ctrl_MemToReg)
           );
 
 WB WB1 (.i_ALU_Data(r_MEMWB_DataOut),
         .i_Mem_Data(r_MEMWB_MemOut),
         .i_ctrl_MemToReg(r_MEMWB_ctrl_MemToReg),
         .i_ctrl_RegWrite(r_MEMWB_ctrl_RegWrite),
         .i_Rd(r_MEMWB_Rd),
         .o_WriteData(w_WB_WriteData),
         .o_ctrl_RegWrite(w_WB_ctrl_RegWrite),
         .o_Rd(w_WB_Rd)
         );
			
 always@(*) begin
	o_WB_DataOut = w_WB_WriteData;
 end
endmodule 