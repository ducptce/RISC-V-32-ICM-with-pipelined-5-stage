module IF
#(parameter DATA_WIDTH = 32,
  parameter MEMORY_WIDTH = 16,
  parameter MEMORY_DEPTH = 2**10)
 (input clk, 
  input n_rst,
  input i_ctrl_PC_Write,
  input i_ctrl_Jump,
  input i_ctrl_EX_Br_taken,
  input [DATA_WIDTH-1:0] i_PC_Jump,
  input [DATA_WIDTH-1:0] i_PC_Branch,
  input i_ctrl_Busy,
  output reg [DATA_WIDTH-1:0] o_PC,
  output reg [DATA_WIDTH-1:0] o_Inst,
  output reg o_ctrl_is_C_inst
  );
  reg [MEMORY_WIDTH-1:0] memory [0:MEMORY_DEPTH-1];
  wire [DATA_WIDTH-1:0] w_Mux_Branch, w_Mux_Jump, w_not_branch_PC;
  wire [DATA_WIDTH-1:0] w_memout, w_Inst;
  wire w_ctrl_is_C_inst;
  
  initial $readmemb("InsMem.txt", memory);
  // PC select
  //assign w_Mux_Jump = (i_ctrl_Jump)?i_PC_Jump:w_Mux_Branch;
  //assign w_Mux_Branch = (i_ctrl_EX_Br_taken)?i_PC_Branch:(o_PC+4);
  assign w_not_branch_PC = o_PC + ((w_ctrl_is_C_inst)?2:4);
  assign w_Mux_Jump = (i_ctrl_Jump)?i_PC_Jump:w_not_branch_PC;
  assign w_Mux_Branch = (i_ctrl_EX_Br_taken)?i_PC_Branch:w_Mux_Jump;
  
  // PC
  always@(posedge clk or negedge n_rst) begin
	 if (!n_rst) begin
		o_PC <= 0;
	 end else begin
		//if (i_ctrl_PC_Write) o_PC <= w_Mux_Jump;
		if (i_ctrl_PC_Write || ~i_ctrl_Busy) o_PC <= w_Mux_Branch;
	 end
  end
  
  // InsMem
  assign w_memout = {memory[(o_PC>>1)+1],memory[o_PC>>1]};
 
  // Decompress Unit
  Decompression_Unit Decomp (.i_low_inst(w_memout[15:0]),
									  .i_high_inst(w_memout[31:16]),
									  .o_ctrl_is_C_inst(w_ctrl_is_C_inst),
									  .o_inst(w_Inst)
									  );

  always@(*) begin
	 o_Inst = w_Inst;
	 o_ctrl_is_C_inst = w_ctrl_is_C_inst;
  end
endmodule

