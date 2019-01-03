`include "defines.v"

module ex(
    input wire rst,
    //ex
    input wire[31:0] pc_i,
    input wire[31:0] reg1_i,
    input wire[31:0] reg2_i,
    input wire[6:0] opcode_i,
    input wire[2:0] funct_i,
    input wire[4:0] wd_i,
    input wire wreg_i,
    input wire[31:0] imm_i,
    //mem
    output reg[2:0] read_o,//000:disable,001:LB,010:LH,011:LW,100:LBU,101:LHU
    output reg[1:0] write_o,//00:diable,01:SB,10:SH,11:SW
    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] waddr_o,//only for load/store
    output reg[31:0] wdata_o
);

    always@(*) begin
        if(rst == 1'b1) begin
            wd_o = 5'b0;
            wreg_o = 1'b0;
            waddr_o = 32'h0;
            wdata_o = 32'h0;
            read_o = 3'b0;
            write_o = 2'b0;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            waddr_o = 32'h0;
            read_o = 3'b0;
            write_o = 2'b0;
            case(opcode_i)
            `LUI:
                wdata_o = imm_i;
            `AUIPC: //??pc changed??
                wdata_o = imm_i + pc_i;
            `JAL: 
                wdata_o = pc_i + 4'h4;
            `JALR: 
                wdata_o = pc_i + 4'h4;
            `L_command:begin
                waddr_o = imm_i + reg1_i;
                wdata_o = 32'h0;
                case(funct_i)
                `LB:
                    read_o = 3'b001;
                `LH:
                    read_o = 3'b010;
                `LW:
                    read_o = 3'b011;
                `LBU:
                    read_o = 3'b100;
                `LHU:
                    read_o = 3'b101;
                endcase
            end
            `S_command:begin
                wdata_o = reg2_i;
                waddr_o = imm_i + reg1_i;
                case(funct_i)
                `SB:
                    write_o = 2'b01;
                `SH:
                    write_o = 2'b10;
                `SW:
                    write_o = 2'b11;
                endcase
            end
            `REG_IMM: begin
                case(funct_i)
                `ADDI:
                    wdata_o = imm_i + reg1_i;
                `SLTI:
                    if($signed(reg1_i) < $signed(imm_i)) begin
                        wdata_o = 32'h1;
                    end else begin 
                        wdata_o = 32'h0;
                    end
                `SLTIU:
                   if(reg1_i < imm_i) begin
                        wdata_o = 32'h1;
                    end else begin 
                        wdata_o = 32'h0;
                    end
                `XORI:
                    wdata_o = reg1_i ^ imm_i;
                `ORI:
                    wdata_o = reg1_i | imm_i;
                `ANDI:
                    wdata_o = reg1_i & imm_i;
                `SLLI:begin
                    wdata_o = reg1_i << imm_i[4:0];
                end
                `SRLI: begin
                    wdata_o = reg1_i >> imm_i[4:0];
                end
                `SRAI: begin 
                    wdata_o = $signed(reg1_i) >>> imm_i[4:0];
                end
                endcase
            end
            `REG_REG:begin
                case(funct_i)
                `ADD: begin
                    if(imm_i == 7'b0) begin
                        wdata_o = reg1_i + reg2_i;
                    end
                    if(imm_i != 7'b0) begin
                        wdata_o = reg1_i - reg2_i;
                    end
                end
                `SLL: begin
                    wdata_o = reg1_i << reg2_i[4:0];
                end
                `SLT: begin
                    wdata_o = ($signed(reg1_i) < $signed(reg2_i));
                end
                `SLTU: begin
                    wdata_o = (reg1_i < reg2_i);
                end
                `SRL: begin
                    wdata_o = reg1_i >> reg2_i[4:0];
                end
                `SRA: begin
                    wdata_o = $signed(reg1_i) >>> reg2_i[4:0];
                end    
                `AND:
                    wdata_o = reg1_i & reg2_i;
                `OR:
                    wdata_o = reg1_i | reg2_i;
                `XOR:
                    wdata_o = reg1_i ^ reg2_i;
                endcase
            end
            endcase
        end
    end

endmodule