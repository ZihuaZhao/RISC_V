module id_ex(
    input wire clk,
    input wire rst,
    //id
    input wire[31:0] id_pc,
    input wire[31:0] id_reg1,
    input wire[31:0] id_reg2,
    input wire[6:0] id_opcode,
    input wire[2:0] id_funct,
    input wire[4:0] id_wd,
    input wire id_wreg,
    input wire[31:0] id_imm,
    //ex
    output reg[31:0] ex_pc,
    output reg[31:0] ex_reg1,
    output reg[31:0] ex_reg2,
    output reg[6:0] ex_opcode,
    output reg[2:0] ex_funct,
    output reg[4:0] ex_wd,
    output reg ex_wreg,
    output reg[31:0] ex_imm
);

    always @(posedge clk) begin
        if(rst == 1'b1) begin
            ex_pc <= 32'h0;
            ex_reg1 <= 32'h0;
            ex_reg2 <= 32'h0;
            ex_opcode <= 7'b0;
            ex_funct <= 3'b0;
            ex_wd <= 5'b0;
            ex_wreg <= 1'b0;
            ex_imm <= 32'h0;
        end else begin
            ex_pc <= id_pc;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_opcode <= id_opcode;
            ex_funct <= id_funct;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_imm <= id_imm;
        end
    end
    
endmodule