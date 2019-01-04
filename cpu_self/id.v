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
    //jump problem
    input wire jump_i,
    output reg jump_o,
    output reg[31:0] jump_addr_o
);
integer i;
//imm
reg[31:0] imm_reg;

    always@(*) begin
        if(rst == 1'b1) begin
            reg1_read_o = 1'b0;
            reg1_addr_o = 5'h0;
            reg2_read_o = 1'b0;
            reg2_addr_o = 5'h0;
            opcode = 7'h0;
            funct = 3'h0;
            wreg_o = 1'b0;
            wd_o = 5'h0;
            imm_reg = 32'h0;
            imm_o = 32'h0;
        end else begin
            reg1_read_o = 1'b0;
            reg1_addr_o = inst_i[19:15];
            reg2_read_o = 1'b0;
            reg2_addr_o = inst_i[24:20];
            opcode = inst_i[6:0];
            funct = inst_i[14:12];
            wreg_o = 1'b0;
            wd_o = inst_i[11:7];
            imm_reg = 32'h0;
            imm_o = 32'h0;
            case(opcode)
            `LUI: begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {inst_i[31:12] , 12'h0};
            end
            `AUIPC: begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {inst_i[31:12] , 12'h0};
            end
            `JAL: begin 
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {{11{inst_i[31]}} , inst_i[31] , inst_i[19:12] , inst_i[20] , inst_i[30:21] , 1'b0};
            end
            `JALR: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {{20{inst_i[31]}} , inst_i[31:20]};
            end
            `B_command: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                wreg_o = 1'b0;
                imm_reg = {{19{inst_i[31]}} , inst_i[31] , inst_i[7] , inst_i[30:25] , inst_i[11:8] , 1'b0};
            end
            `L_command: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {{20{inst_i[31]}} , inst_i[31:20]};
            end
            `S_command: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                wreg_o = 1'b0;
                imm_reg = {{20{inst_i[31]}} , inst_i[31:25] , inst_i[11:7]};
            end
            `REG_IMM: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b0;
                wreg_o = 1'b1;
                imm_reg = {{20{inst_i[31]}} , inst_i[31:20]};
            end
            `REG_REG: begin
                reg1_read_o = 1'b1;
                reg2_read_o = 1'b1;
                wreg_o = 1'b1;
                imm_reg = {25'h0 , inst_i[31:26]};
            end
            endcase
            imm_o = imm_reg;
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
            pc_o = pc_i;
            //forwarding issue
            if(reg1_read_o == 1'b1) begin
                reg1_o = reg1_data_i;
            end
            if(reg2_read_o == 1'b1) begin
                reg2_o = reg2_data_i;
            end
            //jump problem
            if(jump_i == 1'b1) begin 
                if(opcode == `JAL) begin
                    jump_o = 1'b1;
                    jump_addr_o = pc_i + imm_reg;
                end
                if(opcode == `JALR) begin
                    jump_o = 1'b1;
                    jump_addr_o = reg1_o + imm_reg;
                    jump_addr_o[0] = 1'b0;
                end
                if(opcode == `B_command) begin
                    if(funct == `BEQ) begin
                        if(reg1_o == reg2_o) begin
                            jump_o = 1'b1;
                            jump_addr_o = pc_i + imm_reg;
                        end else begin
                            jump_o = 1'b0;
                            jump_addr_o = 32'h0;
                        end
                    end
                    if(funct == `BNE) begin 
                        if(reg1_o != reg2_o) begin 
                            jump_o = 1'b1;
                            jump_addr_o = pc_i + imm_reg;
                        end else begin
                            jump_o = 1'b0;
                            jump_addr_o = 32'h0;
                        end
                    end
                    if(funct == `BLT) begin
                       if($signed(reg1_o) < $signed(reg2_o)) begin
                            jump_o = 1'b1;
                            jump_addr_o = pc_i + imm_reg;
                        end else begin
                            jump_o = 1'b0;
                            jump_addr_o = 32'h0;
                        end
                    end
                    if(funct == `BLTU) begin
                        if(reg1_o < reg2_o) begin
                             jump_o = 1'b1;
                             jump_addr_o = pc_i + imm_reg;
                        end else begin
                             jump_o = 1'b0;
                             jump_addr_o = 32'h0;
                        end
                    end
                    if(funct == `BGE) begin
                        if($signed(reg1_o) < $signed(reg2_o)) begin
                            jump_o = 1'b0;
                            jump_addr_o = 32'h0;
                        end else begin
                            jump_o = 1'b1;
                            jump_addr_o = pc_i + imm_reg;
                        end
                    end
                    if(funct == `BGEU) begin
                       if(reg1_o < reg2_o) begin
                            jump_o = 1'b0;
                            jump_addr_o = 32'h0;
                        end else begin
                            jump_o = 1'b1;
                            jump_addr_o = pc_i + imm_reg;
                        end
                    end
                end
            end else begin
                jump_o = 1'b0;
                jump_addr_o = 32'h0;
            end
        end
    end

endmodule