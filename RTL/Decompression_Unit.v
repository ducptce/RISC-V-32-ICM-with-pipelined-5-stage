module Decompression_Unit (input [15:0] i_low_inst,
									input [15:0] i_high_inst,
                           output reg [31:0] o_inst,
									output reg        o_ctrl_is_C_inst);
									
									
always @(*) begin
	if (i_low_inst[1:0] == 2'b00) begin// Quadrant 0
		o_ctrl_is_C_inst = 1'b1;
		case (i_low_inst[15:13]) 
			3'b000: begin 
				if (i_low_inst[12:5] == 0) o_inst = 0; //illegal instruction
				else begin //c.addi4spn = addi rd', x2, nzuimm
					o_inst[6:0] = 7'b0010011; // The addi-Opcode
					o_inst[11:7] = {2'b01,i_low_inst[4:2]}; // Change rd' to rd
					o_inst[14:12] = 3'b000; // The addi-funct3
					o_inst[19:15] = 5'b00010; // rs1 = x2
					o_inst[31:20] = {2'b00, i_low_inst[10:7], i_low_inst[12:11], i_low_inst[5], i_low_inst[6], 2'b00}; // nzuimm to 12 bit imme
				end
			end
			3'b010: begin // c.lw = lw rd', offset[6:2](rs1')
				o_inst[6:0] = 7'b0000011; // The lw-Opcode
				o_inst[11:7] = {2'b01,i_low_inst[4:2]}; // rd = rd'
				o_inst[14:12] = 3'b010; // The lw-funct3
				o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rs1'
				o_inst[31:20] = {5'h0,i_low_inst[5], i_low_inst[12:10], i_low_inst[6], 2'b00}; // uimm to 12 bit imme
			end
			3'b110: begin // c.sw = sw rs2', offset[6:2](rs1')
				o_inst[6:0] = 7'b0100011; // The sw-Opcode
				o_inst[11:7] = {i_low_inst[11:10], i_low_inst[6], 2'b00}; // uimm[4:0]
				o_inst[14:12] = 3'b010; // The sw-funct3
				o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rs1'
				o_inst[24:20] = {2'b01,i_low_inst[4:2]}; // rs2 = rs2'
				o_inst[31:25] = {5'h0,i_low_inst[5], i_low_inst[12]}; // uimm[11:5]
			end
			default o_inst = 32'h0;
		endcase			
	end 
	else if (i_low_inst[1:0] == 2'b01) begin// Quadrant 1
		o_ctrl_is_C_inst = 1'b1;
		case (i_low_inst[15:13]) 
			3'b000: begin //c.addi = addi rd, rs1, nzuimm
				o_inst[6:0] = 7'b0010011; // The addi-Opcode
				o_inst[11:7] = i_low_inst[11:7]; // rd = rd#0/rs1
				o_inst[14:12] = 3'b000; // The addi-funct3
				o_inst[19:15] = i_low_inst[11:7]; // rs1 = rd#0/rs1
				o_inst[31:20] = {{7{i_low_inst[12]}}, i_low_inst[6:2]}; // nzimm to 12 bit imme
			end
			3'b001: begin //c.jal  = jal x1, offset[11:1]
				o_inst[6:0] = 7'b1101111; // The jal-Opcode
				o_inst[11:7] = 5'b00001; // rd = x1
				o_inst[31:12] = {i_low_inst[12], i_low_inst[8], i_low_inst[10:9], i_low_inst[6], i_low_inst[7], i_low_inst[2], i_low_inst[11], i_low_inst[5:3], {9{i_low_inst[12]}}};
				// 12-bit c.jal imme to 20 bit jal imme
			end
			3'b010: begin //c.li = addi rd#0, x0, imm[5:0]
				o_inst[6:0] = 7'b0010011; // The addi-Opcode
				o_inst[11:7] = i_low_inst[11:7]; // rd = rd#0
				o_inst[14:12] = 3'b000; // The addi-funct3
				o_inst[19:15] = 5'h0; // rs1 = x0
				o_inst[31:20] = {{7{i_low_inst[12]}}, i_low_inst[6:2]}; // imm to 12 bit imme
			end
			3'b011: begin //c.addi16spn, c.lui
				if (i_low_inst[11:7] == 5'h2) begin //c.addi16spn = addi x2, x2, nzimm[9:4] 
					o_inst[6:0] = 7'b0010011; // The addi-Opcode
					o_inst[11:7] = i_low_inst[11:7]; // rd = rd#0/rs1
					o_inst[14:12] = 3'b000; // The addi-funct3
					o_inst[19:15] = i_low_inst[11:7]; // rs1 = rd#0/rs1
					o_inst[31:20] = {{3{i_low_inst[12]}}, i_low_inst[4:3], i_low_inst[5], i_low_inst[2], i_low_inst[6], 4'h0}; // nzimm to 12 bit imme
				end else begin // c.lui = lui rd, nzuimm[17:12]
					o_inst[6:0] = 7'b0110111; // The lui-Opcode
					o_inst[11:7] = i_low_inst[11:7]; // rd = rd #0,2
					o_inst[31:12] = {{15{i_low_inst[12]}}, i_low_inst[6:2]}; //nzuimm extend to 20-bit
				end
			end
			3'b100: begin // ALU i_low_insts
				if (i_low_inst[11:10] == 2'b00) begin //c.srli = srli rd', rd', shamt[5:0] 
					o_inst[6:0] = 7'b0010011; // The srli-Opcode
					o_inst[11:7] = {2'b01,i_low_inst[9:7]}; // rd = rd'
					o_inst[14:12] = 3'b101; // The srli-funct3
					o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rd'
					o_inst[24:20] = i_low_inst[6:2]; // shamt = nzuimm[5:0]
					o_inst[31:25] = 7'h0; // funct_7
				end else if (i_low_inst[11:10] == 2'b01) begin //c.srai = srai rd', rd', shamt[5:0] 
					o_inst[6:0] = 7'b0010011; // The srai-Opcode
					o_inst[11:7] = {2'b01,i_low_inst[9:7]}; // rd = rd'
					o_inst[14:12] = 3'b101; // The srai-funct3
					o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rd'
					o_inst[24:20] = {i_low_inst[6:2]}; // shamt = nzuimm[5:0]
					o_inst[31:25] = 7'b0100000; // funct_7
				end else if (i_low_inst[11:10] == 2'b10) begin //c.andi = andi rd', rd', imm[5:0] 
					o_inst[6:0] = 7'b0010011; // The andi-Opcode
					o_inst[11:7] = {2'b01,i_low_inst[9:7]}; // rd = rd'
					o_inst[14:12] = 3'b111; // The andi-funct3
					o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rd'
					o_inst[31:20] = {{7{i_low_inst[12]}}, i_low_inst[6:2]}; // imm[5:0] extends to 12-bit
				end else begin
					if (i_low_inst[12] == 1'b0) begin // i_low_inst[12] == 1 is reserve
						if (i_low_inst[6:5] == 2'b00) begin //c.sub = sub rd', rd', rs2'
							o_inst[6:0] = 7'b0110011; // sub-opcode
							o_inst[11:7] = {2'b01,i_low_inst[9:7]}; // rd = rd'
							o_inst[14:12] = 3'b000; // The sub-funct3
							o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rd'
							o_inst[24:20] = {2'b01,i_low_inst[4:2]}; // rs2 = rs2'
							o_inst[31:25] = 7'b0100000; // funct_7
						end else if (i_low_inst[6:5] == 2'b01) begin //c.xor = xor rd', rd', rs2'
							o_inst[6:0] = 7'b0110011; // xor-opcode
							o_inst[11:7] = {2'b01,i_low_inst[9:7]}; // rd = rd'
							o_inst[14:12] = 3'b100; // The xor-funct3
							o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rd'
							o_inst[24:20] = {2'b01,i_low_inst[4:2]}; // rs2 = rs2'
							o_inst[31:25] = 7'b0000000; // funct_7
						end else if (i_low_inst[6:5] == 2'b10) begin //c.or = or rd', rd', rs2'
							o_inst[6:0] = 7'b0110011; // or-opcode
							o_inst[11:7] = {2'b01,i_low_inst[9:7]}; // rd = rd'
							o_inst[14:12] = 3'b110; // The or-funct3
							o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rd'
							o_inst[24:20] = {2'b01,i_low_inst[4:2]}; // rs2 = rs2'
							o_inst[31:25] = 7'b0000000; // funct_7
						end else begin //c.and = and rd', rd', rs2'
							o_inst[6:0] = 7'b0110011; // and-opcode
							o_inst[11:7] = {2'b01,i_low_inst[9:7]}; // rd = rd'
							o_inst[14:12] = 3'b111; // The and-funct3
							o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rd'
							o_inst[24:20] = {2'b01,i_low_inst[4:2]}; // rs2 = rs2'
							o_inst[31:25] = 7'b0000000; // funct_7
						end
					end else o_inst = 32'h0;
				end	
			end
			3'b101: begin //c.j = jal x0, offset[11:1]
				o_inst[6:0] = 7'b1101111; // The jal-Opcode
				o_inst[11:7] = 5'b00000; // rd = x0
				o_inst[31:12] = {i_low_inst[12], i_low_inst[8], i_low_inst[10:9], i_low_inst[6], i_low_inst[7], i_low_inst[2], i_low_inst[11], i_low_inst[5:3], {9{i_low_inst[12]}}};
				// 12-bit c.jal imme to 20 bit jal imme
			end
			3'b110: begin // c.beqz = beq rs1', x0, offset[8:1]
				o_inst[6:0] = 7'b1100011; //beq opcode
				o_inst[11:7] = {i_low_inst[11:10], i_low_inst[4:3], i_low_inst[12]}; // imm[4:1|11]
				o_inst[14:12] = 3'b000; // The beq-funct3
				o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rs1'
				o_inst[24:20] = 5'h0; // rs2 = x0
				o_inst[31:25] = {{4{i_low_inst[12]}}, i_low_inst[6:5], i_low_inst[2]}; // imm[12|10:5]
			end
			3'b111: begin // c.bnez = bne rs1', x0, offset[8:1]
				o_inst[6:0] = 7'b1100011; //bne opcode
				o_inst[11:7] = {i_low_inst[11:10], i_low_inst[4:3], i_low_inst[12]}; // imm[4:1|11]
				o_inst[14:12] = 3'b001; // The bne funct3
				o_inst[19:15] = {2'b01,i_low_inst[9:7]}; // rs1 = rs1'
				o_inst[24:20] = 5'h0; // rs2 = x0
				o_inst[31:25] = {{4{i_low_inst[12]}}, i_low_inst[6:5], i_low_inst[2]}; // imm[12|10:5]
			end
			default o_inst = 32'h0;
		endcase
	end
	else if (i_low_inst[1:0] == 2'b10) begin // Quadrant 2
		o_ctrl_is_C_inst = 1'b1;
		case (i_low_inst[15:13]) 
			3'b000: begin //c.slli = slli rd, rs1, nzuimm
				o_inst[6:0] = 7'b0010011; // The slli-Opcode
				o_inst[11:7] = i_low_inst[11:7]; // rd = rd'
				o_inst[14:12] = 3'b001; // The slli-funct3
				o_inst[19:15] = i_low_inst[11:7]; // rs1 = rd'
				o_inst[24:20] = {i_low_inst[6:2]}; // shamt = nzuimm[5:0], nzuimm[5] always zero
				o_inst[31:25] = 7'b0000000; // funct_7
			end
			3'b010: begin //c.lwsp = lw rd, offset[7:2](x2)
				o_inst[6:0] = 7'b0000011; // The lw-Opcode
				o_inst[11:7] = i_low_inst[11:7]; // rd = rd
				o_inst[14:12] = 3'b010; // The lw-funct3
				o_inst[19:15] = 5'd2; // rs1 = x2
				//o_inst[31:20] = {5'h0,i_low_inst[5], i_low_inst[12:10], i_low_inst[6], 2'b00}; // uimm to 12 bit imme
				o_inst[31:20] = {4'b0, i_low_inst[3:2], i_low_inst[12], i_low_inst[6:4], 2'b00}; // uimm to 12 bit imme
			end
			3'b100: begin 
				if (i_low_inst[12] == 1'b0 && i_low_inst[6:2] == 5'd0) begin// c.jr = jalr x0, rs1, 0
					o_inst[6:0] = 7'b1100111; // The jalr Opcode
					o_inst[11:7] = 5'd0; // rd = 0
					o_inst[14:12] = 3'b000; // The jalr-funct3
					o_inst[19:15] = i_low_inst[11:7]; // rs1 = rs1
					o_inst[31:20] = 12'h0; // imme = 0
				end
				else if (i_low_inst[12] == 1'b0 && i_low_inst[6:2] != 5'd0) begin// c.mv = add rd, x0, rs2
					o_inst[6:0] = 7'b0110011; // The add Opcode
					o_inst[11:7] = i_low_inst[11:7]; // rd = rd
					o_inst[14:12] = 3'b000; // The add-funct3
					o_inst[19:15] = 5'd0; // rs1 = x0
					o_inst[24:20] = i_low_inst[6:2]; // rs2 = rs2
					o_inst[31:25] = 7'b0000000; // funct_7
				end
				else if (i_low_inst[12] == 1'b1 && i_low_inst[6:2] == 5'd0) begin// c.jalr = jalr x1, rs1, 0
					o_inst[6:0] = 7'b1100111; // The jalr Opcode
					o_inst[11:7] = 5'd1; // rd = 1
					o_inst[14:12] = 3'b000; // The jalr-funct3
					o_inst[19:15] = i_low_inst[11:7]; // rs1 = rs1
					o_inst[31:20] = 12'h0; // imme = 0
				end
				else begin //c.add = add rd, rd, rs2
					o_inst[6:0] = 7'b0110011; // The add Opcode
					o_inst[11:7] = i_low_inst[11:7]; // rd = rd
					o_inst[14:12] = 3'b000; // The add-funct3
					o_inst[19:15] = i_low_inst[11:7]; // rs1 = rd
					o_inst[24:20] = i_low_inst[6:2]; // rs2 = rs2
					o_inst[31:25] = 7'b0000000; // funct_7
				end
			end
			3'b110: begin //c.swsp = sw rs2, offset[7:2](x2)
				o_inst[6:0] = 7'b0100011; // The sw-Opcode
				o_inst[11:7] = {i_low_inst[11:9], 2'b00}; // uimm[4:0]
				o_inst[14:12] = 3'b010; // The sw-funct3
				o_inst[19:15] = 5'd2; // rs1 = x2
				o_inst[24:20] = i_low_inst[6:2]; // rs2 = rs2
				o_inst[31:25] = {4'h0,i_low_inst[8:7], i_low_inst[12]}; // uimm[11:5]
			end
			default o_inst = 32'hX;
		endcase
	end
	else begin
		o_ctrl_is_C_inst = 1'b0;
		o_inst = {i_high_inst,i_low_inst};
	end
	
end									
endmodule
