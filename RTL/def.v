//		OPCODE
`define AMO 				7'b0101111
`define AUIPC				7'b0010111
`define BRANCH				7'b1100011
`define JAL					7'b1101111
`define JALR				7'b1100111
`define LOAD				7'b0000011
`define LOAD_FP			7'b0000111
`define LUI					7'b0110111
`define MADD				7'b1000011
`define MSUB				7'b1000111
`define NMADD				7'b1001111
`define NMSUB				7'b1001011
`define OP					7'b0110011
`define OP_FP				7'b1010011
`define OP_IMM				7'b0010011
`define STORE				7'b0100011
`define STORE_FP			7'b0100111
		
//		FUNCT3
`define FUNCT3_LB			2'b000
`define FUNCT3_LH			2'b001
`define FUNCT3_LW			2'b010
`define FUNCT3_LBU		2'b100
`define FUNCT3_LHU		2'b101
//`define FUNCT3_LWU		2'b10
`define FUNCT3_ADDI		3'b000
`define FUNCT3_SLLI		3'b001
`define FUNCT3_SLTI		3'b010
`define FUNCT3_SLTIU		3'b011
`define FUNCT3_XORI		3'b100
`define FUNCT3_SRLI		3'b101
`define FUNCT3_SRAI		3'b101
`define FUNCT3_ORI		3'b110
`define FUNCT3_ANDI		3'b111
`define FUNCT3_SB			3'b000
`define FUNCT3_SH			3'b001
`define FUNCT3_SW			3'b010
`define FUNCT3_ADD		3'b000
`define FUNCT3_SUB		3'b000
`define FUNCT3_SLL		3'b001
`define FUNCT3_SLT 		3'b010
`define FUNCT3_SLTU		3'b011
`define FUNCT3_XOR		3'b100
`define FUNCT3_SRL		3'b101
`define FUNCT3_SRA		3'b101
`define FUNCT3_OR			3'b110
`define FUNCT3_AND		3'b111
`define FUNCT3_BEQ		3'b000
`define FUNCT3_BNE		3'b001	
`define FUNCT3_BLT		3'b100
`define FUNCT3_BGE		3'b101
`define FUNCT3_BLTU		3'b110
`define FUNCT3_BGEU		3'b111
`define FUNCT3_JALR		3'b000
`define FUNCT3_MUL		3'b000
`define FUNCT3_MULH		3'b001
`define FUNCT3_MULHSU	3'b010
`define FUNCT3_MULHU		3'b011
`define FUNCT3_DIV		3'b100
`define FUNCT3_DIVU		3'b101
`define FUNCT3_REM		3'b110
`define FUNCT3_REMU		3'b111

//		FUNCT7
`define FUNCT7_SLLI		7'b0000000
`define FUNCT7_SRLI		7'b0000000
`define FUNCT7_SRAI		7'b0100000
`define FUNCT7_ADD		7'b0000000
`define FUNCT7_SUB		7'b0100000
`define FUNCT7_SLL		7'b0000000
`define FUNCT7_SLT 		7'b0000000
`define FUNCT7_SLTU		7'b0000000
`define FUNCT7_XOR		7'b0000000
`define FUNCT7_SRL		7'b0000000
`define FUNCT7_SRA		7'b0100000
`define FUNCT7_OR			7'b0000000
`define FUNCT7_AND		7'b0000000
`define FUNCT7_MUL		7'b0000001
`define FUNCT7_MULH		7'b0000001
`define FUNCT7_MULHSU	7'b0000001
`define FUNCT7_MULHU		7'b0000001
`define FUNCT7_DIV		7'b0000001
`define FUNCT7_DIVU		7'b0000001
`define FUNCT7_REM		7'b0000001
`define FUNCT7_REMU		7'b0000001