module stall(
    input wire rst,
    input wire id_stall_i,
    input wire mem_stall_i,
    output reg stall1,
    output reg stall2,
    output reg stall3,
    output reg stall4
);

    always@(*) begin
        if(rst == 1'b1) begin
            stall1 <= 1'b0;
            stall2 <= 1'b0;
            stall3 <= 1'b0;
            stall4 <= 1'b0;
        end else begin
            if(id_stall_i == 1'b1) begin
                stall1 = 1'b1;
                stall2 = 1'b1;
                stall3 = 1'b0;
                stall4 = 1'b0;
            end else if(mem_stall_i == 1'b1) begin
                stall1 = 1'b1;
                stall2 = 1'b1;
                stall3 = 1'b1;
                stall4 = 1'b0;
            end else begin 
                stall1 <= 1'b0;
                stall2 <= 1'b0;
                stall3 <= 1'b0;
                stall4 <= 1'b0;
            end
        end
    end

endmodule