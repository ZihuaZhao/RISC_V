module mem_controller(
    input wire clk,
    input wire rst,
    //mem
    input wire[7:0] mem_data_i,
    output reg[31:0] mem_addr_o,
    output reg[7:0] mem_data_o,
    output reg mem_wr_o,
    //if
    input wire if_i,
    input wire[31:0] if_addr_i,
    output reg[31:0] if_addr_o,
    output reg if_busy_o,
    output reg[31:0] if_data_o,
    //load
    input wire[2:0] read_i,
    input wire[31:0] read_addr_i,
    output reg read_busy_o,
    output reg[31:0] read_data_o,
    //store
    input wire[1:0] write_i,
    input wire[31:0] write_addr_i,
    input wire[31:0] write_data_i,
    output reg write_busy_o
);

//if addr/data reg
integer if_en;//0:disable,1-4:read cycle;
reg[31:0] if_addr_reg;
reg[31:0] if_data_reg;
//load addr/data reg
reg[2:0] read_num_reg;//000:disable,001:LB,010:LH,011:LW,100:LBU,101:LHU
integer read_en;//0:disable.1-4:read cycle;
reg[31:0] read_addr_reg;
reg[31:0] read_data_reg;
//store addr/data reg,
reg[1:0] write_num_reg;//00:diable,01:SB,10:SH,11:SW
integer write_en;//0:disable,1-4:write cycle;
reg[31:0] write_addr_reg;
reg[31:0] write_data_reg;

    always@(*) begin
        if(rst == 1'b1) begin
            mem_addr_o = 32'h0;
            mem_data_o = 8'h0;
            mem_wr_o = 1'b0;
            if_addr_o = 32'h0;
            if_data_o = 32'h0;
            if_busy_o = 1'b1;
            read_data_o = 32'h0;
            read_busy_o = 1'b1;
            write_busy_o = 1'b1;
            if_addr_reg = 32'h0;
            if_data_reg = 32'h0;
            read_num_reg = 3'b0;
            read_addr_reg = 32'h0;
            read_data_reg = 32'h0;
            write_num_reg = 2'b0;
            write_addr_reg = 32'h0;
            write_data_reg = 32'h0;
            if_en = 0;
            read_en = 0;
            write_en = 0;
        end else begin
            if_busy_o = 1'b0;
            read_busy_o = 1'b0;
            write_busy_o = 1'b0;
            if(if_i == 1'b1) begin
                if_addr_reg = if_addr_i;
                if_data_reg = 32'h0;
            end
            if(read_i != 3'b0) begin
                read_num_reg = read_i;
                read_addr_reg = read_addr_i;
                read_data_reg = 32'h0;
            end
            if(write_i != 2'b0) begin
                write_num_reg = write_i;
                write_addr_reg = write_addr_i;
                write_data_reg = write_data_i;
            end
            if(if_en != 0) begin
                //read/write do
                read_data_o = 32'h0;
                read_data_reg = 32'h0;
                if(read_addr_reg != 32'h0) begin
                    read_busy_o = 1'b1;
                end else begin
                    read_busy_o = 1'b0;
                end
                if(write_addr_reg != 32'h0) begin
                    write_busy_o = 1'b1;
                end else begin
                    write_busy_o = 1'b0;
                end
                //mem do
                mem_data_o = 32'h0;
                if(if_en == 1) begin
                    if_data_reg[7:0] = mem_data_i[7:0];
                    if_busy_o = 1'b1;
                    if_en = 2;
                    mem_addr_o = if_addr_reg + 1;
                    mem_wr_o = 1'b0;
                end else if(if_en == 2) begin
                    if_data_reg[15:8] = mem_data_i[7:0];
                    if_busy_o = 1'b1;
                    if_en = 3;
                    mem_addr_o = if_addr_reg + 2;
                    mem_wr_o = 1'b0;
                end else if(if_en == 3) begin
                    if_data_reg[23:16] = mem_data_i[7:0];
                    if_busy_o = 1'b1;
                    if_en = 4;
                    mem_addr_o = if_addr_reg + 3;
                    mem_wr_o = 1'b0;
                end else if(if_en == 4) begin
                    if_data_o[31:24] = mem_data_i[7:0];
                    if_data_o[23:0] = if_data_reg[23:0];
                    if_addr_o = if_addr_reg;
                    if_busy_o = 1'b0;
                    if_en = 0;
                end
            end
            if(read_en != 0) begin
                //if/write do
                if_data_o = 32'h0;
                if_data_reg = 32'h0;
                if(if_addr_reg != 32'h0) begin
                    if_busy_o = 1'b1;
                end else begin 
                    if_busy_o = 1'b0;
                end
                if(write_addr_reg != 32'h0) begin
                    write_busy_o = 1'b1;
                end else begin
                    write_busy_o = 1'b0;
                end
                //mem do
                mem_data_o = 32'h0;
                if(read_en == 1) begin
                    if(read_num_reg == 3'b001 || read_num_reg == 3'b100) begin
                        read_data_o[7:0] = mem_data_i[7:0];
                        read_busy_o = 1'b0;
                        read_en = 0;
                    end else begin
                        read_data_reg[7:0] = mem_data_i[7:0];
                        read_busy_o = 1'b1;
                        read_en = 2;
                        mem_addr_o = read_addr_reg + 1;
                        mem_wr_o = 1'b0;
                    end
                end else if(read_en == 2) begin
                    if(read_num_reg == 3'b010 || read_num_reg == 3'b101) begin 
                        read_data_o[15:8] = mem_data_i[7:0];
                        read_data_o[7:0] = read_data_reg[7:0];
                        read_busy_o = 1'b0;
                        read_en = 0;
                    end else begin
                        read_data_reg[15:8] = mem_data_i[7:0];
                        read_busy_o = 1'b1;
                        read_en = 3;
                        mem_addr_o = read_addr_reg + 2;
                        mem_wr_o = 1'b0;
                    end
                end else if(read_en == 3) begin
                    read_data_reg[23:16] = mem_data_i[7:0];
                    read_busy_o = 1'b1;
                    read_en = 4;
                    mem_addr_o = read_addr_reg + 3;
                    mem_wr_o = 1'b0;
                end else if(read_en == 4) begin
                    read_data_o[31:24] = mem_data_i[7:0];
                    read_data_o[23:0] = read_data_reg[23:0];
                    read_en = 0;
                end
            end
            if(write_en != 0) begin
                //if/read do
                if_data_o = 32'h0;
                if_data_reg = 32'h0;
                if(if_addr_reg != 32'h0) begin
                    if_busy_o = 1'b1;
                end else begin 
                    if_busy_o = 1'b0;
                end
                read_data_o = 32'h0;
                read_data_reg = 32'h0;
                if(read_addr_reg != 32'h0) begin
                    read_busy_o = 1'b1;
                end else begin
                    read_busy_o = 1'b0;
                end
                //mem do
                if(write_en == 1) begin
                    if(write_num_reg == 1'b01) begin
                        write_busy_o = 1'b0;
                        write_en = 0;
                    end else begin
                        write_busy_o = 1'b1;
                        write_en = 2;
                        mem_addr_o = write_addr_reg + 1;
                        mem_data_o = write_data_reg[15:8];
                        mem_wr_o = 1'b1;
                    end
                end else if(write_en == 2) begin
                    if(write_num_reg == 1'b1) begin
                        write_busy_o = 1'b0;
                        write_en = 0;
                    end else begin
                        write_busy_o = 1'b1;
                        write_en = 3;
                        mem_addr_o = write_addr_reg + 2;
                        mem_data_o = write_data_reg[23:16];
                        mem_wr_o = 1'b1;
                    end
                end else if(write_en == 3) begin
                    write_busy_o = 1'b1;
                    write_en = 4;
                    mem_addr_o = write_addr_reg + 3;
                    mem_data_o = write_data_reg[31:24];
                    mem_wr_o = 1'b1;
                end else if(write_en == 4) begin
                    write_busy_o = 1'b0;
                    write_en = 0;
                end
            end
            if(if_en == read_en == write_en == 0) begin
                if(read_addr_reg != 32'h0) begin
                    read_en = 1;
                    mem_addr_o = read_addr_reg;
                    mem_wr_o = 1'b0;
                end else if(write_addr_reg != 32'h0) begin
                    write_en = 1;
                    mem_addr_o = write_addr_reg;
                    mem_data_o = write_data_reg[7:0];
                    mem_wr_o = 1'b1;
                end else if(if_addr_reg != 32'h0) begin
                    if_en = 1;
                    mem_addr_o = if_addr_reg;
                    mem_wr_o = 1'b0;
                end
            end
        end
    end

endmodule