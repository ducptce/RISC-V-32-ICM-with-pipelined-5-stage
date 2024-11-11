module Hazard_Detection 
(input [4:0] i_rs1,
 input [4:0] i_rs2,
 input i_ctrl_EX_MemRead,
 input i_ctrl_MEM_MemRead,
 input [4:0] i_EX_rd,
 input [4:0] i_MEM_rd,
 input i_ctrl_EX_Br_taken,
 input i_ctrl_Jump,
 input i_ctrl_Branch,
 input i_ctrl_JALR,
 input i_ctrl_EX_RegWrite,
 input i_ctrl_EX_Busy,
 output reg o_ctrl_PC_Write,
 output reg o_ctrl_IFID_Write,
 output reg o_ctrl_flush,
 output reg o_ctrl_kill,
 output reg o_ctrl_IDEX_Write,
 output reg o_ctrl_EXMEM_Write,
 output reg o_ctrl_MEMWB_Write 
 );
 wire w_ctrl_Branch_Hazard_EX_DataNotReady;
 wire w_ctrl_Branch_Hazard_MEM_MemDataNotReady;
 wire w_ctrl_JALR_Hazard_EX_DataNotReady;
 wire w_ctrl_JALR_Hazard_MEM_MemDataNotRead;
 wire w_ctrl_Br_taken, w_ctrl_DataNotReady;
 wire w_ctrl_Data_Hazard_EX_LoadNotReady;
 
 assign w_ctrl_Br_taken = (i_ctrl_EX_Br_taken || i_ctrl_Jump);
 assign w_ctrl_Branch_Hazard_MEM_MemDataNotReady = (i_ctrl_Branch && i_ctrl_MEM_MemRead && i_MEM_rd != 5'd0 && (i_MEM_rd == i_rs1 || i_MEM_rd == i_rs2));
 assign w_ctrl_Branch_Hazard_EX_DataNotReady = (i_ctrl_Branch && (i_ctrl_EX_RegWrite || i_ctrl_MEM_MemRead) && i_EX_rd != 5'd0 && (i_EX_rd == i_rs1 || i_EX_rd == i_rs2));
 assign w_ctrl_JALR_Hazard_EX_DataNotReady = (i_ctrl_JALR && i_ctrl_EX_RegWrite && i_EX_rd != 5'd0 && i_EX_rd == i_rs1);
 assign w_ctrl_JALR_Hazard_MEM_MemDataNotRead = (i_ctrl_JALR && i_ctrl_MEM_MemRead && i_MEM_rd != 5'd0 && i_MEM_rd == i_rs1);
 assign w_ctrl_Data_Hazard_EX_LoadNotReady = (i_ctrl_EX_MemRead && i_EX_rd != 5'd0 && (i_EX_rd == i_rs1 || i_EX_rd == i_rs2));
 assign w_ctrl_DataNotReady = w_ctrl_Data_Hazard_EX_LoadNotReady | w_ctrl_Branch_Hazard_MEM_MemDataNotReady | w_ctrl_Branch_Hazard_EX_DataNotReady | w_ctrl_JALR_Hazard_EX_DataNotReady | w_ctrl_JALR_Hazard_MEM_MemDataNotRead;
 
 always@(*) begin 
	if(w_ctrl_DataNotReady) begin
		o_ctrl_PC_Write = 1'b0;
		o_ctrl_IFID_Write = 1'b0;
		o_ctrl_flush = 1'b1;
		o_ctrl_kill = 1'b0;
	end else if(w_ctrl_Br_taken) begin
		o_ctrl_PC_Write = 1'b1;
		o_ctrl_IFID_Write = 1'b1;
		o_ctrl_flush = 1'b1;
		o_ctrl_kill = 1'b1;
	end else begin
		o_ctrl_PC_Write = ~i_ctrl_EX_Busy;
		o_ctrl_IFID_Write = ~i_ctrl_EX_Busy;
		o_ctrl_flush = 1'b0;
		o_ctrl_kill = 1'b0;
	end
	
	if(i_ctrl_EX_Busy) begin
		o_ctrl_IDEX_Write = 1'b0;
		o_ctrl_EXMEM_Write = 1'b0;
		o_ctrl_MEMWB_Write = 1'b0;
	end else begin
		o_ctrl_IDEX_Write = 1'b1;
		o_ctrl_EXMEM_Write = 1'b1;
		o_ctrl_MEMWB_Write = 1'b1;
	end
 end
endmodule 