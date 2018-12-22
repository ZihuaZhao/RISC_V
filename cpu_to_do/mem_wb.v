module mem_wb(
    input wire clk,
    input wire rst,

    input wire[4:0] mem_wd,
    input wire mem_wreg,
    input wire[31:0] mem_wdata,
    input wire stall_i,

    output reg wb_wreg,
    output reg[4:0] wb_wd,
    output reg[31:0] wb_wdata,
    output reg stall_o
);

    always@(posedge clk) begin
        if(rst == 1'b1) begin
            wb_wreg <= 1'b0;
            wb_wd <= 5'b0;
            wb_wdata <= 32'h0;
            stall_o <= 1'b0;
        end else begin 
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            stall_o <= stall_i;
        end
    end

endmodule