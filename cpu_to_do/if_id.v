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
    input wire jump_i
);

    always@(posedge clk) begin
        if(rst == 1'b1) begin
            id_pc <= 32'h0;
            id_inst <= 32'h0;
        end else begin
            if(if_busy_i == 1'b1) begin
                id_pc <= 32'h0;
                id_inst <= 32'h0;
            end else begin
                if(jump_i == 1'b1) begin
                    id_pc <= 32'h0;
                    id_inst <= 32'h0;
                end else begin
                    id_pc <= if_pc;
                    id_inst <= if_inst;
                end
            end
        end
    end

endmodule