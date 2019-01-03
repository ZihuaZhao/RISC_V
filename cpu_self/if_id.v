module if_id(
    input wire clk,
    input wire rst,
    //mem input
    input wire if_busy_i,
    input wire[31:0] if_pc,
    input wire[31:0] if_inst,
    //if_id output
    output reg[31:0] id_pc,
    output reg[31:0] id_inst,
    //jump
    input wire jump_i,
    output reg jump_com,
    //stall
    input wire stall2
);
reg jump;
reg stall_reg;
reg[31:0] pc_reg;
reg[31:0] inst_reg;

    always@(posedge clk) begin
        if(rst == 1'b1) begin
            id_pc <= 32'h0;
            id_inst <= 32'h0;
            jump <= 1'b0;
            jump_com <= 1'b1;
            pc_reg <= 32'h0;
            inst_reg <= 32'h0;
            stall_reg <= 1'b0;
        end else begin
            if(stall2 == 1'b1) begin
                id_pc <= 32'h0;
                id_inst <= 32'h0;
                if(if_busy_i == 1'b0 && if_pc != 32'h0) begin
                    stall_reg <= 1'b1;
                    pc_reg <= if_pc;
                    inst_reg <= if_inst;
                end
            end else begin
                if(jump_i == 1'b1) begin
                    jump <= 1'b1;
                    jump_com <= 1'b0;
                end
                if(stall_reg == 1'b1) begin
                    stall_reg <= 1'b0;
                    id_pc <= pc_reg;
                    id_inst <= inst_reg;
                end else begin
                    if(if_busy_i == 1'b1) begin
                        id_pc <= 32'h0;
                        id_inst <= 32'h0;
                    end else begin
                        if(jump == 1'b1) begin
                            id_pc <= 32'h0;
                            id_inst <= 32'h0;
                            jump <= 1'b0;
                            jump_com <= 1'b1;
                        end else begin
                            id_pc <= if_pc;
                            id_inst <= if_inst;
                        end
                    end
                end
            end
        end
    end

endmodule