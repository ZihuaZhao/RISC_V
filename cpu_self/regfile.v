module regfile(
    input wire clk,
    input wire rst,

    input wire we,
    input wire[4:0] waddr,
    input wire[31:0] wdata,

    input wire re1,
    input wire[4:0] raddr1,
    output reg[31:0] rdata1,

    input wire re2,
    input wire[4:0] raddr2,
    output reg[31:0] rdata2
);
//regs
integer i;
reg[31:0] regs[31:0];

    //write
    always@(posedge clk) begin
        if(rst == 1'b0) begin
            if(we != 1'b0 && waddr != 5'b0) begin
                regs[waddr] <= wdata;
            end
        end else begin
            for(i = 0 ; i < 32 ; i = i + 1) begin
                regs[i] <= 32'h0;
            end
        end
    end

    //read1
    always@(*) begin
        if(rst == 1'b1) begin
            rdata1 = 32'h0;
        end else if((raddr1 == waddr) && (re1 == 1'b1) && (we == 1'b1)) begin
            rdata1 = wdata;
        end else if(re1 == 1'b1) begin
            rdata1 = regs[raddr1];
        end else begin
            rdata1 = 32'h0;
        end
    end

    //read2
    always@(*) begin
        if(rst == 1'b1) begin
            rdata2 = 32'h0;
        end else if((raddr2 == waddr) && (re2 == 1'b1) && (we == 1'b1)) begin
            rdata2 = wdata;
        end else if(re2 == 1'b1) begin
            rdata2 = regs[raddr2];
        end else begin
            rdata2 = 32'h0;
        end
    end

endmodule