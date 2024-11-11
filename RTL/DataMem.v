module DataMem
#(parameter DATA_WIDTH = 32,
  parameter MEMORY_DEPTH = 2**15,
  parameter MEMORY_WIDTH = 32)
(input clk,
 input n_rst,
 input i_ctrl_MemRead,
 input i_ctrl_MemWrite,
 input [2:0] i_ctrl_Mem_Mode,
 input [DATA_WIDTH-1:0] i_Addr,
 input [DATA_WIDTH-1:0] i_WriteData,
 output reg [DATA_WIDTH-1:0] o_MemOut
 );
 integer i = 0;
reg [MEMORY_WIDTH-1:0] memory [MEMORY_DEPTH-1:0];

// Data signal
wire [29:0] word_addr;
wire [1:0] offset;

// Control signal
wire [1:0] w_ctrl_Mode;
wire w_ctrl_UnsignLoad;

assign word_addr = i_Addr[31:2];
assign offset = i_Addr[1:0];
assign w_ctrl_Mode = i_ctrl_Mem_Mode[1:0];
assign w_ctrl_UnsignLoad = i_ctrl_Mem_Mode[2];

always@(*) begin
	//w_ctrl_Mode == 2'b00: load/store byte
	//w_ctrl_Mode == 2'b01: load/store half word
	//w_ctrl_Mode == 2'b10: load/store word
	if(i_ctrl_MemRead) begin
		case(w_ctrl_Mode)
			2'b00: 
				begin
					case(offset)
						2'b00: o_MemOut = (w_ctrl_UnsignLoad)?{24'b0, memory[word_addr][7:0]}:{{24{memory[word_addr][7]}}, memory[word_addr][7:0]};
						2'b01: o_MemOut = (w_ctrl_UnsignLoad)?{24'b0, memory[word_addr][15:8]}:{{24{memory[word_addr][15]}}, memory[word_addr][15:8]};
						2'b10: o_MemOut = (w_ctrl_UnsignLoad)?{24'b0, memory[word_addr][23:16]}:{{24{memory[word_addr][23]}}, memory[word_addr][23:16]};
						2'b11: o_MemOut = (w_ctrl_UnsignLoad)?{24'b0, memory[word_addr][31:24]}:{{24{memory[word_addr][31]}}, memory[word_addr][31:24]};
					endcase
				end
			2'b01: 
				begin
					case(offset[1])
						1'b0: o_MemOut = (w_ctrl_UnsignLoad)?{16'b0, memory[word_addr][15:0]}:{{16{memory[word_addr][15]}}, memory[word_addr][15:0]};
						1'b1: o_MemOut = (w_ctrl_UnsignLoad)?{16'b0, memory[word_addr][31:16]}:{{16{memory[word_addr][31]}}, memory[word_addr][31:16]};
					endcase
				end
			2'b10: o_MemOut = memory[word_addr];
			default: o_MemOut = 32'b0;
		endcase
	end else begin
		o_MemOut = 32'bz;
	end
end

always@(posedge clk) begin
	if(!n_rst) begin
		//$readmemb("DataMem_Init.txt", memory);
		for(i = 0; i < MEMORY_DEPTH; i = i + 1) begin
			memory[i] = 32'd0;
		end
		$writememb("DataMem.txt", memory);
	end else begin
		if(i_ctrl_MemWrite) begin
			case(w_ctrl_Mode)
				2'b00: 
					begin
						case(offset)
							2'b00: memory[word_addr][7:0] <= i_WriteData[7:0];
							2'b01: memory[word_addr][15:8] <= i_WriteData[7:0];
							2'b10: memory[word_addr][23:16] <= i_WriteData[7:0];
							2'b11: memory[word_addr][31:24] <= i_WriteData[7:0];
						endcase
					end
				2'b01: 
					begin
						case(offset[1])
							1'b0: memory[word_addr][15:0] <= i_WriteData[15:0];
							1'b1: memory[word_addr][31:16] <= i_WriteData[15:0];
						endcase
					end
				2'b10: memory[word_addr] <= i_WriteData;
				default: memory[word_addr] <= memory[word_addr];
			endcase
			//#1 
			//$display("addr %b", i_Addr);
			//$display("%b", memory[word_addr]);
		end else begin
			memory[word_addr] <= memory[word_addr];
		end
	end
end

always@(*) $writememb("DataMem.txt", memory);
endmodule