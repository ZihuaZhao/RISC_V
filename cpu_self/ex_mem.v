module ex_mem(
    input wire clk,
    input wire rst,
    //ex
    input wire[2:0] ex_read,
    input wire[1:0] ex_write,
    input wire[4:0] ex_wd,
    input wire ex_wreg,
    input wire[31:0] ex_waddr,
    input wire[31:0] ex_wdata,
    //mem
    output reg[2:0] mem_read,
    output reg[1:0] mem_write,
    output reg[4:0] mem_wd,
    output reg mem_wreg,
    output reg[31:0] mem_waddr,
    output reg[31:0] mem_wdata,
    //stall4
    input wire stall4
);

    always@(posedge clk) begin
        if(rst == 1'b1 || stall4 == 1'b1) begin
            mem_read <= 3'b0;
            mem_write <= 2'b0;
            mem_wd <= 5'h0;
            mem_wreg <= 1'b0;
            mem_waddr <= 32'h0;
            mem_wdata <= 32'h0;
        end else begin
            mem_read <= ex_read;
            mem_write <= ex_write;
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_waddr <= ex_waddr;
            mem_wdata <= ex_wdata;
        end
    end

endmodule