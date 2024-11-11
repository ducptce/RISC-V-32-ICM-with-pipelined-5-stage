module Multiplier
#(parameter DATA_WIDTH = 32)
(input clk,
 input n_rst,
 input i_ctrl_Start,
 input i_ctrl_Unsigned,
 input i_ctrl_HSU,
 input [DATA_WIDTH-1:0] i_A,
 input [DATA_WIDTH-1:0] i_B,
 output reg [2*DATA_WIDTH-1:0] o_Product,
 output reg o_ctrl_Done
 );
 
 reg [DATA_WIDTH-1:0] r_Multiplier;
 reg [2*DATA_WIDTH-1:0] r_Multiplicand;
 reg [6:0] r_Counter;
 wire w_ctrl_Start;
 wire [2*DATA_WIDTH-1:0] w_2s_Multiplicand;
 
 assign w_2s_Multiplicand = ~r_Multiplicand + {{(2*DATA_WIDTH-1){1'b0}}, 1'b1};
 
 always@(posedge clk or negedge n_rst) begin
	if(!n_rst) begin
		r_Counter <= 0;
	end else if(r_Counter == 0) begin
		r_Counter <= {6'b0, i_ctrl_Start};
	end else if(r_Counter + 7'd1 == 7'd34) begin
		r_Counter <= 0;
	end else begin
		r_Counter <= r_Counter + 7'd1;
	end
 end 
 
 always@(*) begin
	if(r_Counter == 0) begin
		o_ctrl_Done = ~i_ctrl_Start;
	end else if(r_Counter == 33) begin
		o_ctrl_Done = 1'b1;
	end else begin
		o_ctrl_Done = 1'b0;
	end 
 end
 
 always@(posedge clk or negedge n_rst) begin
	if(!n_rst) begin
		o_Product <= 0;
		r_Multiplier <= 0;
		r_Multiplicand <= 0;
	end else if(r_Counter == 0) begin
		r_Multiplicand <= (i_ctrl_Unsigned)?{{(DATA_WIDTH){1'b0}}, i_A}:{{(DATA_WIDTH){i_A[DATA_WIDTH-1]}}, i_A};
		r_Multiplier <= i_B;
		o_Product <= 0;
	end else begin
		r_Multiplicand <= r_Multiplicand << 1;
		r_Multiplier <= r_Multiplier >> 1;
		if(r_Counter == 33 && i_ctrl_HSU) begin
			if(r_Multiplier[0]) o_Product <= o_Product + w_2s_Multiplicand;
			else o_Product <= o_Product;	
		end else begin
			if(r_Multiplier[0]) o_Product <= o_Product + r_Multiplicand;
			else o_Product <= o_Product;
		end
	end
 end
endmodule 