//commands
`define LUI 7'b0110111
`define AUIPC 7'b0010111
`define JAL 7'b1101111
`define JALR 7'b1100111
`define B_command 7'b1100011
`define L_command 7'b0000011
`define S_command 7'b0100011
`define REG_IMM 7'b0100011
`define REG_REG 7'b0110011

//funct
`define BEQ 3'b000
`define BNE 3'b001 
`define BLT 3'b100 
`define BGE 3'b101 
`define BLTU 3'b110 
`define BGEU 3'b111 

`define LB 3'b000 
`define LH 3'b001
`define LW 3'b010 
`define LBU 3'b100 
`define LHU 3'b101 

`define SB 3'b000 
`define SH 3'b001 
`define SW 3'b010 

`define ADDI 3'b000 
`define SLTI 3'b010 
`define SLTIU 3'b011
`define XORI 3'b100
`define ORI 3'b110 
`define ANDI 3'b111 
`define SLLI 3'b001 
`define SRLI 3'b101
`define SRAI 3'b101 

`define ADD 3'b000 
`define SUB 3'b000
`define SLL 3'b001
`define SLT 3'b010 
`define SLTU 3'b011 
`define XOR 3'b100 
`define SRL 3'b101 
`define SRA 3'b101 
`define OR 3'b110 
`define AND 3'b111 