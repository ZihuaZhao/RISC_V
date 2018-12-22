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

//
integer if_en;
reg if_num_reg;
reg[31:0] if_addr_reg;
reg[31:0] if_data_reg;
//
integer read_en;
reg[2:0] read_num_reg;
reg[31:0] read_addr_reg;
reg[31:0] read_data_reg;
//
integer write_en;
reg[1:0] write_num_reg;
reg[31:0] write_addr_reg;
reg[31:0] write_data_reg;

    //if_in/read_in/write_in
    always@(*) begin
        if(if_i != 1'b0) begin
            if_num_reg = 1'b1;
            if_addr_reg = if_addr_i;
            if_busy_o = 1'b1;
        end
        if(read_i != 3'b0) begin
            read_num_reg = read_i;
            read_addr_reg = read_addr_i;
            read_busy_o = 1'b1;
        end
        if(write_i != 2'b0) begin
            write_num_reg = write_i;
            write_addr_reg = write_addr_i;
            write_data_reg = write_data_i;
            write_busy_o = 1'b1;
        end
    end

    //mem
    always@(posedge clk) begin
        if(rst == 1'b1) begin
            mem_addr_o = 32'h0;
            mem_data_o = 32'h0;
            mem_wr_o = 1'b0;
            if_addr_o = 32'h0;
            if_data_o = 32'h0;
            if_busy_o = 1'b0;
            read_busy_o = 1'b0;
            read_data_o = 32'h0;
            write_busy_o = 1'b0;
            if_en = 0;
            if_num_reg = 1'b0;
            if_addr_reg = 32'h0;
            if_data_reg = 32'h0;
            read_en = 0;
            read_num_reg = 3'b0;
            read_addr_reg = 32'h0;
            read_data_reg = 32'h0;
            write_en = 0;
            write_num_reg = 2'b0;
            write_addr_reg = 32'h0;
            write_data_reg = 32'h0;
        end else begin
            mem_addr_o = 32'h0;
            mem_data_o = 32'h0;
            mem_wr_o = 1'b0;
            if_addr_o = 32'h0;
            if_data_o = 32'h0;
            if_busy_o = 1'b1;
            read_busy_o = 1'b1;
            read_data_o = 32'h0;
            write_busy_o = 1'b1;
            if(if_en != 0) begin
                case(if_en)
                1: begin
                    mem_addr_o = if_addr_reg;
                end
                2: begin
                    if_data_reg[7:0] = mem_data_i;
                end
                3: begin
                    mem_addr_o = if_addr_reg + 1;
                end
                4: begin
                    if_data_reg[15:8] = mem_data_i;
                end
                5: begin
                    mem_addr_o = if_addr_reg + 2;
                end
                6: begin
                    if_data_reg[23:16] = mem_data_i;
                end
                7: begin
                    mem_addr_o = if_addr_reg + 3;
                end
                8: begin
                    if_addr_o = if_addr_reg;
                    if_data_o[31:24] = mem_data_i;
                    if_data_o[23:0] = if_data_reg[23:0];
                    if_num_reg = 1'b0;
                    if_addr_reg = 32'h0;
                    if_data_reg = 32'h0;
                    if_busy_o = 1'b0;
                end
                endcase
                if_en = (if_en + 1) % 9;
            end
            if(read_en != 0) begin
                case(read_en)
                1: begin
                    mem_addr_o = read_addr_reg;
                end
                2: begin
                    if(read_num_reg == 3'b001 || read_num_reg == 3'b100) begin
                        read_data_o[7:0] = mem_data_i;
                        read_addr_reg = 32'h0;
                        read_data_reg = 32'h0;
                        read_num_reg = 3'b000;
                        read_en = 0;
                        read_busy_o = 1'b0;
                    end else begin
                        read_data_reg[7:0] = mem_data_i;
                        read_en = 3;
                    end
                end
                3: begin
                    mem_addr_o = read_addr_reg + 1;
                end
                4: begin
                    if(read_num_reg == 3'b010 || read_num_reg == 3'b101) begin
                        read_data_o[15:8] = mem_data_i;
                        read_data_o[7:0] = read_data_reg[7:0];
                        read_addr_reg = 32'h0;
                        read_data_reg = 32'h0;
                        read_num_reg = 3'b000;
                        read_en = 0;
                        read_busy_o = 1'b0;
                    end else begin
                        read_data_reg[15:8] = mem_data_i;
                        read_en = 5;
                    end
                end
                5: begin
                    mem_addr_o = read_addr_reg + 2;
                end
                6: begin 
                    read_data_reg[23:16] = mem_data_i;
                    read_en = 7;
                end
                7: begin 
                    mem_addr_o = read_addr_reg + 3;
                end
                8: begin
                    read_data_o[31:24] = mem_data_i;
                    read_data_o[23:0] = read_data_reg[23:0];
                    read_addr_reg = 32'h0;
                    read_data_reg = 32'h0;
                    read_num_reg = 3'b000;
                    read_en = 0;
                    read_busy_o = 1'b0;
                end
                endcase
            end
            if(write_en != 0) begin
                case(write_en)
                1: begin
                    mem_addr_o = write_addr_reg;
                    mem_data_o = write_data_reg[7:0];
                    mem_wr_o = 1'b1;
                end
                2: begin
                    if(read_num_reg == 2'b01) begin
                        write_addr_reg = 32'h0;
                        write_data_reg = 32'h0;
                        write_num_reg = 3'b000;
                        write_en = 0;
                        write_busy_o = 1'b0;
                    end else begin
                        read_en = 3;
                    end
                end
                3: begin
                    mem_addr_o = write_addr_reg;
                    mem_data_o = write_data_reg[15:8];
                    mem_wr_o = 1'b1;
                end
                4: begin
                    if(read_num_reg == 2'b10) begin
                        write_addr_reg = 32'h0;
                        write_data_reg = 32'h0;
                        write_num_reg = 3'b000;
                        write_en = 0;
                        write_busy_o = 1'b0;
                    end else begin
                        read_en = 5;
                    end
                end
                5: begin
                    mem_addr_o = write_addr_reg;
                    mem_data_o = write_data_reg[23:16];
                    mem_wr_o = 1'b1;
                end
                6: begin
                    read_en = 7;
                end
                7: begin 
                    mem_addr_o = write_addr_reg;
                    mem_data_o = write_data_reg[31:24];
                    mem_wr_o = 1'b1;
                end
                8: begin
                    write_addr_reg = 32'h0;
                    write_data_reg = 32'h0;
                    write_num_reg = 3'b000;
                    write_en = 0;
                    write_busy_o = 1'b0;
                end
                endcase
            end
            if(if_en == 1'b0 && read_en == 3'b000 && write_en == 2'b00) begin
                if(if_num_reg == 1'b1 && read_num_reg == 3'b000 && write_num_reg == 2'b00) begin
                    if_busy_o = 1'b0;
                    read_busy_o = 1'b0;
                    write_busy = 1'b0;
                end else if(read_num_reg != 3'b000) begin
                        read_en = 1;
                    end else if(write_num_reg != 2'b00) begin
                        write_en = 1;
                    end else if(if_num_reg != 1'b0) begin
                        if_en = 1;
                    end
            end
        end
    end

endmodule