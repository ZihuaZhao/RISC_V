// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	  input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

//
//pc_if
//
wire stall1_wire;
wire if_busy_wire;
wire if_en_wire;
wire [31:0] if_pc_wire;
wire jump_wire;
wire [31:0] jump_pc_wire;
wire jump_com_wire;

pc_if pc_if_mod(
  .clk(clk_in),
  .rst(rst_in),
  .stall1(stall1_wire),
  .if_busy_i(if_busy_wire),
  .if_o(if_en_wire),
  .pc_o(if_pc_wire),
  .jump_i(jump_wire),
  .pc_i(jump_pc_wire)
);

//
//mem_controller
//
wire[31:0] mem_pc_wire;
wire[31:0] if_data_wire;
wire[2:0] read_en_wire;
wire[31:0] read_addr_wire;
wire read_busy_wire;
wire[31:0] read_data_wire;
wire[1:0] write_en_wire;
wire[31:0] write_addr_wire;
wire[31:0] write_data_wire;
wire write_busy_wire;
wire finish_wire;

mem_controller mem_controller_mod(
  .clk(clk_in),
  .rst(rst_in),
  .mem_data_i(mem_din),
  .mem_addr_o(mem_a),
  .mem_data_o(mem_dout),
  .mem_wr_o(mem_wr),
  .if_i(if_en_wire),
  .if_addr_i(if_pc_wire),
  .if_addr_o(mem_pc_wire),
  .if_busy_o(if_busy_wire),
  .if_data_o(if_data_wire),
  .read_i(read_en_wire),
  .read_addr_i(read_addr_wire),
  .read_busy_o(read_busy_wire),
  .read_data_o(read_data_wire),
  .write_i(write_en_wire),
  .write_addr_i(write_addr_wire),
  .write_data_i(write_data_wire),
  .write_busy_o(write_busy_wire),
  .finish(finish_wire)
);

//
//if_id
//
wire stall2_wire;
wire[31:0] ifid_pc_wire;
wire[31:0] ifid_inst_wire;

if_id if_id_mod(
  .clk(clk_in),
  .rst(rst_in),
  .if_busy_i(if_busy_wire),
  .if_pc(mem_pc_wire),
  .if_inst(if_data_wire),
  .id_pc(ifid_pc_wire),
  .id_inst(ifid_inst_wire),
  .jump_i(jump_wire),
  .jump_com(jump_com_wire),
  .stall2(stall2_wire)
);

//
//id
//
wire[31:0] regfile_reg1_data_wire;
wire[31:0] regfile_reg2_data_wire;
wire regfile_reg1_en_wire;
wire regfile_reg2_en_wire;
wire[4:0] regfile_reg1_addr_wire;
wire[4:0] regfile_reg2_addr_wire;
wire[31:0] id_pc_wire;
wire[31:0] id_reg1_wire;
wire[31:0] id_reg2_wire;
wire[6:0] id_opcode_wire;
wire[2:0] id_funct_wire;
wire id_wreg_wire;
wire[4:0] id_wd_wire;
wire[31:0] id_imm_wire;
wire wb_en_wire;
wire[4:0] wb_addr_wire;

id id_mod(
  .rst(rst_in),
  .pc_i(ifid_pc_wire),
  .inst_i(ifid_inst_wire),
  .reg1_data_i(regfile_reg1_data_wire),
  .reg2_data_i(regfile_reg2_data_wire),
  .reg1_read_o(regfile_reg1_en_wire),
  .reg2_read_o(regfile_reg2_en_wire),
  .reg1_addr_o(regfile_reg1_addr_wire),
  .reg2_addr_o(regfile_reg2_addr_wire),
  .pc_o(id_pc_wire),
  .reg1_o(id_reg1_wire),
  .reg2_o(id_reg2_wire),
  .opcode(id_opcode_wire),
  .funct(id_funct_wire),
  .wreg_o(id_wreg_wire),
  .wd_o(id_wd_wire),
  .imm_o(id_imm_wire),
  .jump_o(jump_wire),
  .jump_addr_o(jump_pc_wire),
  .jump_i(jump_com_wire)
);

//
//regfile
//
wire[31:0] wb_data_wire;

regfile regfile_mod(
  .clk(clk_in),
  .rst(rst_in),
  .we(wb_en_wire),
  .waddr(wb_addr_wire),
  .wdata(wb_data_wire),
  .re1(regfile_reg1_en_wire),
  .raddr1(regfile_reg1_addr_wire),
  .rdata1(regfile_reg1_data_wire),
  .re2(regfile_reg2_en_wire),
  .raddr2(regfile_reg2_addr_wire),
  .rdata2(regfile_reg2_data_wire)
);

//
//id_ex
//
wire[31:0] idex_pc_wire;
wire[31:0] idex_reg1_wire;
wire[31:0] idex_reg2_wire;
wire[6:0] idex_opcode_wire;
wire[2:0] idex_funct_wire;
wire[4:0] idex_wd_wire;
wire idex_wreg_wire;
wire[31:0] idex_imm_wire;
wire stall3_wire;

id_ex id_ex_mod(
  .clk(clk_in),
  .rst(rst_in),
  .id_pc(id_pc_wire),
  .id_reg1(id_reg1_wire),
  .id_reg2(id_reg2_wire),
  .id_opcode(id_opcode_wire),
  .id_funct(id_funct_wire),
  .id_wd(id_wd_wire),
  .id_wreg(id_wreg_wire),
  .id_imm(id_imm_wire),
  .ex_pc(idex_pc_wire),
  .ex_reg1(idex_reg1_wire),
  .ex_reg2(idex_reg2_wire),
  .ex_opcode(idex_opcode_wire),
  .ex_funct(idex_funct_wire),
  .ex_wd(idex_wd_wire),
  .ex_wreg(idex_wreg_wire),
  .ex_imm(idex_imm_wire),
  .stall3(stall3_wire)
);

//
//ex
//
wire[2:0] ex_read_wire;
wire[1:0] ex_write_wire;
wire[4:0] ex_wd_wire;
wire ex_wreg_wire;
wire[31:0] ex_waddr_wire;
wire[31:0] ex_wdata_wire;

ex ex_mod(
  .rst(rst_in),
  .pc_i(idex_pc_wire),
  .reg1_i(idex_reg1_wire),
  .reg2_i(idex_reg2_wire),
  .opcode_i(idex_opcode_wire),
  .funct_i(idex_funct_wire),
  .wd_i(idex_wd_wire),
  .wreg_i(idex_wreg_wire),
  .imm_i(idex_imm_wire),
  .read_o(ex_read_wire),
  .write_o(ex_write_wire),
  .wd_o(ex_wd_wire),
  .wreg_o(ex_wreg_wire),
  .waddr_o(ex_waddr_wire),
  .wdata_o(ex_wdata_wire)
);

//
//ex_mem
//

wire[2:0] exmem_read_wire;
wire[1:0] exmem_write_wire;
wire[4:0] exmem_wd_wire;
wire exmem_wreg_wire;
wire[31:0] exmem_waddr_wire;
wire[31:0] exmem_wdata_wire;
wire stall4_wire;

ex_mem ex_mem(
  .clk(clk_in),
  .rst(rst_in),
  .ex_read(ex_read_wire),
  .ex_write(ex_write_wire),
  .ex_wd(ex_wd_wire),
  .ex_wreg(ex_wreg_wire),
  .ex_waddr(ex_waddr_wire),
  .ex_wdata(ex_wdata_wire),
  .mem_read(exmem_read_wire),
  .mem_write(exmem_write_wire),
  .mem_wd(exmem_wd_wire),
  .mem_wreg(exmem_wreg_wire),
  .mem_waddr(exmem_waddr_wire),
  .mem_wdata(exmem_wdata_wire),
  .stall4(stall4_wire)
);

//
//mem
//
wire mem_stall_wire;
wire[4:0] mem_wd_wire;
wire mem_wreg_wire;
wire[31:0] mem_wdata_wire;
wire stall_1_wire;

mem mem_mod(
  .rst(rst_in),
  .read_i(exmem_read_wire),
  .write_i(exmem_write_wire),
  .wd_i(exmem_wd_wire),
  .wreg_i(exmem_wreg_wire),
  .waddr_i(exmem_waddr_wire),
  .wdata_i(exmem_wdata_wire),
  .read_busy_i(read_busy_wire),
  .read_data_i(read_data_wire),
  .read_o(read_en_wire),
  .read_addr_o(read_addr_wire),
  .write_busy_i(write_busy_wire),
  .write_o(write_en_wire),
  .write_addr_o(write_addr_wire),
  .write_data_o(write_data_wire),
  .mem_stall(mem_stall_wire),
  .wd_o(mem_wd_wire),
  .wreg_o(mem_wreg_wire),
  .wdata_o(mem_wdata_wire),
  .finish(finish_wire),
  .stall_o(stall_1_wire)
);

//
//mem_wb
//
wire memwb_wreg_wire;
wire[4:0] memwb_wd_wire;
wire[31:0] memwb_wdata_wire;
wire stall_2_wire;

mem_wb me_wb_mod(
  .clk(clk_in),
  .rst(rst_in),
  .mem_wd(mem_wd_wire),
  .mem_wreg(mem_wreg_wire),
  .mem_wdata(mem_wdata_wire),
  .wb_wreg(memwb_wreg_wire),
  .wb_wd(memwb_wd_wire),
  .wb_wdata(memwb_wdata_wire),
  .stall_i(stall_1_wire),
  .stall_o(stall_2_wire)
);

//
//wb
//
wire wb_stall_wire;

wb wb_mod(
  .rst(rst_in),
  .wd_i(memwb_wd_wire),
  .wreg_i(memwb_wreg_wire),
  .wdata_i(memwb_wdata_wire),
  .wreg_o(wb_en_wire),
  .wd_o(wb_addr_wire),
  .wdata_o(wb_data_wire),
  .stall_i(stall_2_wire),
  .stall_o(wb_stall_wire)
);

//
//stall
//

stall stall_mod(
  .rst(rst_in),
  .mem_stall_i(mem_stall_wire),
  .stall1(stall1_wire),
  .stall2(stall2_wire),
  .stall3(stall3_wire),
  .stall4(stall4_wire),
  .wb_stall_wire(wb_stall_wire)
);

endmodule