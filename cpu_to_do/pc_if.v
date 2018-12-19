module pc_if(
    input wire clk,
    input wire rst,
    input wire stall1,
    //mem_controller
    input wire if_busy_i,
    output reg if_o,
    output reg[31:0] pc_o,
    //jump
    input wire jump_i,
    input wire[31:0] pc_i
);

//pc_reg
reg[31:0] pc;
//jump_reg
reg jump;
reg[31:0] pc_jump;

 
    always@(posedge clk) begin
        if(rst == 1'b1) begin
            if_o <= 1'b0;
            pc_o <= 32'h0;
            jump <= 1'b0;
            pc_jump <= 32'h0;
            pc <= 32'h0;
        end else begin
            if_o <= 1'b0;
            pc_o <= 32'h0;
        end
    end

    always@(*) begin
        if(jump_i == 1'b1) begin
            jump = jump_i;
            pc_jump <= pc_i;
        end
        if(if_busy_i == 1'b1) begin
            if_o = 1'b0;
            pc_o = 32'h0;
        end else begin
            if(stall1 == 1'b1) begin
                if_o = 1'b0;
                pc_o = 32'h0;
            end else begin
                if(jump == 1'b1) begin
                    if_o = 1'b1;
                    pc_o = pc_jump;
                    pc = pc_jump + 4'h4;
                    jump = 1'b0;
                    pc_jump = 32'h0;
                end else begin
                    if_o = 1'b1;
                    pc_o = pc;
                    pc = pc + 4'h4;
                end
            end
        end
    end

endmodule