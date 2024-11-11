module MEM 
#(parameter DATA_WIDTH = 32)
 (input             		clk,
  input             		n_rst,
  input 					i_ctrl_MemRead,
  input 					i_ctrl_MemWrite,
  input 					i_ctrl_RegWrite,
  input						i_ctrl_MemToReg,
  input [2:0]       		i_ctrl_Mem_Mode,
  input [4:0]       		i_Rd,
  input [DATA_WIDTH-1:0] 	i_Addr,
  input [DATA_WIDTH-1:0] 	i_WriteData,
  input [DATA_WIDTH-1:0] i_nPC,
  input [DATA_WIDTH-1:0] i_Imme,
  input i_ctrl_LUI,
  input i_ctrl_Jump,
  output reg [4:0]       	o_Rd,
  output reg [DATA_WIDTH-1:0] o_MemOut,
  output reg [DATA_WIDTH-1:0] o_DataOut,
  output reg				o_ctrl_RegWrite,
  output reg 				o_ctrl_MemToReg
 );
//mode[1:0] : funct3[1:0]
//mode == 2'b00: load/store byte
//mode == 2'b01: load/store half word
//mode == 2'b10: load/store word 

wire [DATA_WIDTH-1:0] w_MemOut, w_mux_LUI, w_Addr;

assign w_mux_LUI = (i_ctrl_LUI)?i_Imme:i_Addr;
assign w_Addr = (i_ctrl_Jump)?i_nPC:w_mux_LUI;

DataMem DMEM(.clk(clk),
			    .n_rst(n_rst),
			    .i_ctrl_MemRead(i_ctrl_MemRead),
			    .i_ctrl_MemWrite(i_ctrl_MemWrite),
			    .i_ctrl_Mem_Mode(i_ctrl_Mem_Mode),
			    .i_Addr(w_Addr),
			    .i_WriteData(i_WriteData),
			    .o_MemOut(w_MemOut)
			    );

always@(*) begin
	o_Rd = i_Rd;
	o_MemOut = w_MemOut;
	o_DataOut = w_Addr;
	o_ctrl_RegWrite = i_ctrl_RegWrite;
	o_ctrl_MemToReg = i_ctrl_MemToReg;
end

endmodule
