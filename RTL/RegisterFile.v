module RegisterFile
#(parameter DATA_WIDTH = 32,
  parameter MEMORY_DEPTH = 32)
(input wire clk, n_rst,
 input wire [4:0] i_rs1,
 input wire [4:0] i_rs2,
 input wire [4:0] i_rd,
 input wire [DATA_WIDTH-1:0] i_WriteData,
 input wire i_ctrl_RegWrite,
 output reg [DATA_WIDTH-1:0] o_Read1,
 output reg [DATA_WIDTH-1:0] o_Read2
 );
reg [DATA_WIDTH-1:0] memory [0:MEMORY_DEPTH-1];

always@(*) begin
	o_Read1 = memory[i_rs1];
	o_Read2 = memory[i_rs2];
end

always@(posedge clk or negedge n_rst) begin
	if (!n_rst) begin
		$readmemb("RegisterFile_Init.txt", memory);
		$writememb("RegisterFile.txt", memory);
	end else begin
		if(i_ctrl_RegWrite && i_rd != 5'h0) begin
			memory[i_rd] <= i_WriteData;
			//#1 $display("register %b", i_rd);
			//	$display("%b", memory[i_rd]);
		end
	end
end

always@(*) $writememb("RegisterFile.txt", memory);
endmodule 