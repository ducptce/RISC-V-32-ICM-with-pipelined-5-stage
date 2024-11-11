module Divider 
#(parameter DATA_WIDTH = 32)
(input clk,
 input n_rst,
 input i_ctrl_Start,
 input i_ctrl_Unsigned,
 input [DATA_WIDTH-1:0] i_A,
 input [DATA_WIDTH-1:0] i_B,
 output reg [DATA_WIDTH-1:0] o_Remainder,
 output reg [DATA_WIDTH-1:0] o_Quotient,
 output reg o_ctrl_Done
 );
	reg [2*DATA_WIDTH-1:0] r_Divisor, r_Remainder;
	reg [DATA_WIDTH-1:0] r_Quotient;
	wire [DATA_WIDTH-1:0] w_absA, w_absB;
	reg [6:0] r_Counter;
	wire w_ctrl_Start;
	
	function signed [DATA_WIDTH-1:0] ABS;
		input signed [DATA_WIDTH-1:0] i_In;
		
		begin
			ABS = (i_In < 0)?-i_In:i_In;
		end
	endfunction 

	assign w_absA = ABS(i_A);
	assign w_absB = ABS(i_B);
	
	assign w_ctrl_Start = (r_Counter == 0)?i_ctrl_Start:1'b0;
 
	always@(posedge clk or negedge n_rst) begin
		if(!n_rst) begin
			r_Counter <= 0;
		end else if(w_ctrl_Start) begin
			r_Counter <= 7'd1;
		end else if(r_Counter != 0) begin
			if(r_Counter + 7'd1 == 7'd35) begin
				r_Counter <= 0;
			end else begin
				r_Counter <= r_Counter + 7'd1;
			end
		end
	end 
	 
	 always@(*) begin
		if(r_Counter == 0) begin
			o_ctrl_Done = ~w_ctrl_Start;
		end else if(r_Counter == 7'd34) begin
			o_ctrl_Done = 1'b1;
		end else begin
			o_ctrl_Done = 1'b0;
		end 
	 end
 
	always@(posedge clk or negedge n_rst) begin
		if(!n_rst) begin
			r_Divisor <= 0;
			r_Remainder <= 0;
			r_Quotient <= 0;
		end else if(w_ctrl_Start) begin
			if(i_ctrl_Unsigned) begin
				r_Remainder <= {{DATA_WIDTH{1'b0}}, i_A};
				r_Divisor <= {i_B, {DATA_WIDTH{1'b0}}};
			end else begin
				r_Remainder <= (i_A[DATA_WIDTH-1])?{{DATA_WIDTH{1'b0}}, w_absA}:{{DATA_WIDTH{1'b0}}, i_A};
				r_Divisor <= (i_B[DATA_WIDTH-1])?{w_absB, {DATA_WIDTH{1'b0}}}:{i_B, {DATA_WIDTH{1'b0}}};
			end
		end else begin
			if(r_Remainder < r_Divisor) begin
				r_Quotient <= r_Quotient << 1;
				r_Divisor <= r_Divisor >> 1;
			end else begin
				r_Remainder <= r_Remainder - r_Divisor;
				r_Quotient = r_Quotient << 1;
				r_Quotient[0] = 1'b1;
				r_Divisor <= r_Divisor >> 1;
			end
		end
	end
	
	always@(*) begin
		if(i_ctrl_Unsigned) begin
			o_Remainder = r_Remainder[DATA_WIDTH-1:0];
			o_Quotient = r_Quotient;
		end else begin
			o_Remainder = (i_A[DATA_WIDTH-1])?(-1*r_Remainder[DATA_WIDTH-1:0]):r_Remainder[DATA_WIDTH-1:0];
			o_Quotient = (i_A[DATA_WIDTH-1] ^ i_B[DATA_WIDTH-1])?(-1*r_Quotient):r_Quotient;
		end
	end
endmodule 

