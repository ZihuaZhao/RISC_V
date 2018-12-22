`include "defines.v"

module id(
    input wire rst,
    //if_id input
    input wire[31:0] pc_i,
    input wire[31:0] inst_i,
    //regfile
    input wire[31:0] reg1_data_i,
    input wire[31:0] reg2_data_i,
    output reg reg1_read_o,
    output reg[4:0] reg1_addr_o,
    output reg reg2_read_o,
    output reg[4:0] reg2_addr_o,
    //id_ex
    output reg[31:0] pc_o,
    output reg[31:0] reg1_o,
    output reg[31:0] reg2_o,
    output reg[6:0] opcode,
    output reg[2:0] funct,
    output reg wreg_o,
    output reg[4:0] wd_o,
    output reg[31:0] imm_o,
    //stall
    input wire stall,
    //forwarding
    input wire for1_i,
    input wire[4:0] for1_addr_i,
    input wire[31:0] for1_data_i,
    input wire for2_i,
    input wire[4:0] for2_addr_i,
    input wire[31:0] for2_data_i,
    //jump problem
    output reg jump_o,
    output reg[31:0] jump_addr_o
);

//imm
reg[31:0] imm_reg;
//stall 
reg stall_reg;
reg[31:0] pc_reg;
reg[31:0] inst_reg;

    always@(*) begin
        if(rst == 1'b1) begin
            reg1_read_o = 1'b0;
            reg1_addr_o = 5'h0;
            reg2_read_o = 1'b0;
            reg2_addr_o = 5'h0;
            //pc_o = 32'h0;
            //reg1_o = 32'h0;
            //reg2_o = 32'h0;
            opcode = 7'h0;
            funct = 3'h0;
            wreg_o = 1'b0;
            wd_o = 5'h0;
            imm_reg = 32'h0;
            imm_o = 32'h0;
            stall_reg = 1'b0;
            pc_reg = 32'h0;
            inst_reg = 32'h0;            
        end else begin
            if(stall == 1'b0) begin
                if(stall_reg == 1'b1) begin
                    stall_reg = 1'b0;
                end else begin
                    pc_reg = pc_i;
                    inst_reg = inst_i;
                end
            end
            reg1_read_o = 1'b0;
            reg1_addr_o = inst_reg[19:15];
            reg2_read_o = 1'b0;
            reg2_addr_o = inst_reg[24:20];
            //pc_o = pc_i;
            //reg1_o = 32'h0;
            //reg2_o = 32'h0;
            opcode = inst_reg[6:0];
            funct = inst_reg[14:12];
            wreg_o = 1'b0;
            wd_o = inst_reg[11:7];
            imm_reg = 32'h0;
            imm_o = 32'h0;
            case(opcode)
            `LUI: begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {inst_reg[31:12] , 12'h0};
            end
            `AUIPC: begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {inst_reg[31:12] , 12'h0};
            end
            `JAL: begin 
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {11'h0 , inst_reg[31] , inst_reg[19:12] , inst_reg[20] , inst_reg[30:21] , 1'b0};
            end
            `JALR: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {20'h0 , inst_reg[31:20]};
            end
            `B_command: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                wreg_o = 1'b0;
                imm_reg = {20'h0 , inst_reg[31] , inst_reg[7] , inst_reg[30:25] , inst_reg[11:8]};
            end
            `L_command: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {20'h0 , inst_reg[31:20]};
            end
            `S_command: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                wreg_o = 1'b0;
                imm_reg = {20'h0 , inst_reg[31:25] , inst_reg[11:7]};
            end
            `REG_IMM: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {20'h0 , inst_reg[31:20]};
            end
            `REG_REG: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                wreg_o = 1'b1;
                imm_reg = {25'h0 , inst_reg[31:26]};
            end
            endcase
            imm_o = imm_reg;
            if(stall == 1'b1) begin
                if(pc_i == 32'h0) begin
                    stall_reg = 1'b1;
                end else begin
                    stall_reg = 1'b1;
                    pc_reg = pc_i;
                    inst_reg = inst_i;
                end
                wreg_o = 1'b0;
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                reg1_addr_o = 4'b0;
                reg2_addr_o = 4'b0;
                opcode = 7'b0;
                funct = 3'h0;
                wd_o = 5'h0;
            end
        end
    end

    always@(*) begin
        if(rst == 1'b1) begin 
            jump_o = 1'b0;
            jump_addr_o = 5'h0;
            reg1_o = 32'h0;
            reg2_o = 32'h0;
            pc_o = 32'h0;
        end else begin
            reg1_o = 32'h0;
            reg2_o = 32'h0;
            pc_o = pc_reg;
            jump_o = 1'b0;
            jump_addr_o = 32'h0;
            //forwarding issue
            if(reg1_read_o == 1'b1) begin
                reg1_o = reg1_data_i;
            end
            if(reg2_read_o == 1'b1) begin
                reg2_o = reg2_data_i;
            end
            //jump problem
            if(opcode == `JAL) begin
                jump_o = 1'b1;
                jump_addr_o = pc_reg + imm_reg;
            end
            if(opcode == `JALR) begin
                jump_o = 1'b1;
                jump_addr_o = pc_reg + imm_reg;
                jump_addr_o[0] = 1'b0;
            end
            if(opcode == `B_command) begin
                if(funct == `BEQ) begin
                    if(reg1_o == reg2_o) begin
                        jump_o = 1'b1;
                        jump_addr_o = pc_reg + imm_reg;
                    end
                end
                if(funct == `BNE) begin 
                    if(reg1_o != reg2_o) begin 
                        jump_o = 1'b1;
                        jump_addr_o = pc_reg + imm_reg;
                    end
                end
                if(funct == `BLT || funct == `BLTU) begin
                    if(reg1_o < reg2_o) begin
                        jump_o = 1'b1;
                        jump_addr_o = pc_reg + imm_reg;
                    end
                end
                if(funct == `BGE || funct == `BGEU) begin
                    if(reg1_o >= reg2_o) begin
                        jump_o = 1'b1;
                        jump_addr_o = pc_reg + imm_reg;
                    end
                end
            end
            //stall
            if(stall == 1'b1) begin
                reg1_o = 32'h0;
                reg2_o = 32'h0;
                pc_o = 32'h0;
                jump_o = 1'b0;
                jump_addr_o = 32'h0;
                imm_o = 32'h0;
            end
        end
    end

endmodule