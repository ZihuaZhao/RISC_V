module mem(
    input wire rst,
    //ex
    input wire[2:0] read_i,
    input wire[1:0] write_i,
    input wire[4:0] wd_i,
    input wire wreg_i,
    input wire[31:0] waddr_i,
    input wire[31:0] wdata_i,
    //read
    input wire read_busy_i,
    input wire[31:0] read_data_i,
    output reg[2:0] read_o,
    output reg[31:0] read_addr_o,
    input wire finish,
    //write
    input wire write_busy_i,
    output reg[1:0] write_o,
    output reg[31:0] write_addr_o,
    output reg[31:0] write_data_o,
    //stall
    output reg mem_stall,
    //wb
    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] wdata_o,
    output reg stall_o
);

reg[2:0] read_en_reg;
reg[31:0] read_addr_reg;
reg[1:0] write_en_reg;
reg[31:0] write_addr_reg;
reg[31:0] write_data_reg;

reg[4:0] wd_reg;
reg wreg_reg;
    //ex_input
    always@(*) begin
        if(rst == 1'b1) begin
            read_o = 3'b0;
            read_addr_o = 32'h0;
            write_o = 2'b0;
            write_addr_o = 32'h0;
            write_data_o = 32'h0;
            read_en_reg = 3'b0;
            read_addr_reg = 32'h0;
            write_en_reg = 2'b0;
            write_addr_reg = 32'h0;
            write_data_reg = 32'h0;
        end else begin
            if(read_en_reg != 3'b0) begin
                if(read_busy_i != 1'b1) begin
                    read_o = read_en_reg;
                    read_addr_o = read_addr_reg;
                    write_o = 2'b0;
                    write_addr_o = 32'h0;
                    write_data_o = 32'h0;
                end
            end
            if(write_en_reg != 2'b0) begin
                if(write_busy_i != 1'b1) begin
                    write_o = write_en_reg;
                    write_addr_o = write_addr_reg;
                    write_data_o = write_data_reg;
                    read_o = 3'b0;
                    read_addr_o = 32'h0;
                end
            end
            if(read_i != 3'b0) begin
                read_en_reg = read_i;
                read_addr_reg = waddr_i;
            end
            if(write_i != 2'b0) begin
                write_en_reg = write_i;
                write_addr_reg = waddr_i;
                write_data_reg = wdata_i;
            end
        end
    end

    //mem_input
    always@(*) begin
        if(rst == 1'b1) begin
            wd_o = 5'b0;
            wreg_o = 1'b0;
            wdata_o = 32'h0;
            mem_stall = 1'b0;
            wd_reg = 5'h0;
            wreg_reg = 1'h0;
            stall_o = 1'b0;
        end else begin
            stall_o = 1'b0;
            if(read_i == 3'b0 && write_i == 2'b0) begin
                wd_o = wd_i;
                wreg_o = wreg_i;
                wdata_o = wdata_i;
            end else begin
                wd_reg = wd_i;
                wreg_reg = wreg_i;
            end
            if(read_en_reg != 3'b0) begin
                if(read_busy_i == 1'b1) begin
                    mem_stall = 1'b1;
                end
            end
            if(write_en_reg != 2'b0) begin
                if(write_busy_i == 1'b1) begin
                    mem_stall = 1'b1;
                end
            end
            if(finish != 1'b0) begin
                if(read_busy_i != 1'b1) begin
                    wd_o = wd_reg;
                    wreg_o = wreg_reg;
                    mem_stall = 1'b0;
                    wdata_o = read_data_i;
                    read_en_reg = 3'b0;
                    read_addr_reg = 32'h0;
                    read_o = 3'b0;
                    read_addr_o = 32'h0;
                    stall_o = 1'b1;
                end
            end
            if(finish != 1'b0) begin
                if(write_busy_i != 1'b1) begin
                    wd_o = wd_reg;
                    wreg_o = wreg_reg;
                    mem_stall = 1'b0;
                    write_en_reg = 2'b0;
                    write_addr_reg = 32'h0;
                    write_data_reg = 32'h0;
                    write_o = 2'b0;
                    write_addr_o = 32'h0;
                    write_data_o = 32'h0;
                    stall_o = 1'b1;
                end
            end
        end
    end

endmodule