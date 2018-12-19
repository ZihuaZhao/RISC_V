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
    //write
    input wire write_busy_i,
    output reg[1:0] write_o,
    output reg[31:0] write_addr_o,
    output reg[31:0] write_data_o,
    //stall
    input wire stall,
    output reg mem_stall,
    //forwarding issue
    output reg for2_o,
    output reg[5:0] for2_addr_o,
    output reg[31:0] for2_data_o,
    //wb
    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] wdata_o
);

    //ex_input
    always@(*) begin
        if(rst == 1'b1) begin
            read_o = 3'b0;
            read_addr_o = 32'h0;
            write_o = 2'b0;
            write_addr_o = 32'h0;
            write_data_o = 32'h0;
            for2_addr_o = 5'h0;
            for2_data_o = 32'H0;
            for2_o = 1'b0;
        end else begin
            for2_o = wreg_i;
            for2_addr_o = wd_i;
            for2_data_o = wdata_i;
            if(read_i != 3'b0) begin
                if(read_busy_i != 1'b1) begin
                    read_o = read_i;
                    read_addr_o = waddr_i;
                    write_o = 2'b0;
                    write_addr_o = 32'h0;
                    write_data_o = 32'h0;
                end
            end
            if(write_i != 2'b0) begin
                if(write_busy_i != 1'b1) begin
                    write_o = write_i;
                    write_addr_o = waddr_i;
                    write_data_o = wdata_i;
                    read_o = 3'b0;
                    read_addr_o = 32'h0;
                end
            end
            if(stall == 1'b1) begin
                read_o = 3'b0;
                read_addr_o = 32'h0;
                write_o = 2'b0;
                write_addr_o = 32'h0;
                write_data_o = 32'h0;
                for2_addr_o = 5'h0;
                for2_data_o = 32'H0;
                for2_o = 1'b0;
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
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            if(read_i != 3'b0) begin
                if(read_busy_i == 1'b1) begin
                    mem_stall = 1'b1;
                end else begin
                    wdata_o = read_data_i;
                end
            end
            if(write_i != 2'b0) begin
                if(write_busy_i == 1'b1) begin
                    mem_stall = 1'b1;
                end
            end
            if(stall == 1'b1) begin
                wd_o = 5'b0;
                wreg_o = 1'b0;
                wdata_o = 32'h0;
            end
        end
    end

endmodule