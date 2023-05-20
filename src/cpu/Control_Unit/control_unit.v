/*
Módulo control unit processador
*/
module control_unit (
  input [31:0] insn, // instrução
  input clk, reset,// sinal para que a máquina saia do IDLE, clock e reset
  input lu, ls, eq, // flags de comparação
  output [31:0] code, // code do módulo opdecoder
  output [4:0] rs1_addr, rs2_addr, rd_addr, // endereços para regfile
  output reg [2:0] func3,
  output [2:0] sel_mem_extension, // func3 e seletor extensão memória
  output reg [1:0] sel_rd,
  output [1:0] sel_mem_size, // seletor rd e tamanho escrita memória
	output reg sel_pc_next, sel_pc_alu, load_data_memory, write_mem, load_pc_alu, load_flags, // seletores do program counter e da entrada A da alu
  output reg load_pc, load_ins, load_regfile, load_rs1, load_rs2, load_alu, load_imm,// loads
  output reg sel_alu_a, sel_alu_b, sub_sra // seletor de entrada B da alu, e sinal de sub ou shift right aritmético
);
wire start_alu_fsm, start_branch_jump_fsm, start_load_store_fsm;
wire [2:0] func3_fsm_alu, func3_fsm_branch_jump, func3_fsm_load_store;
wire [1:0] sel_rd_fsm_alu, sel_rd_fsm_branch_jump, sel_rd_fsm_load_store;

wire sel_pc_next_fsm_alu, sel_pc_next_fsm_branch_jump, sel_pc_next_fsm_load_store;
wire sel_pc_alu_fsm_alu, sel_pc_alu_fsm_branch_jump, sel_pc_alu_fsm_load_store;
wire load_data_memory_fsm_alu, load_data_memory_fsm_branch_jump, load_data_memory_fsm_load_store;
wire write_mem_fsm_alu, write_mem_fsm_branch_jump, write_mem_fsm_load_store;
wire load_pc_alu_fsm_alu, load_pc_alu_fsm_branch_jump, load_pc_alu_fsm_load_store;
wire load_flags_fsm_alu, load_flags_fsm_branch_jump, load_flags_fsm_load_store;
wire load_pc_fsm_alu, load_pc_fsm_branch_jump, load_pc_fsm_load_store;
wire load_ins_fsm_alu, load_ins_fsm_branch_jump, load_ins_fsm_load_store;
wire load_regfile_fsm_alu, load_regfile_fsm_branch_jump, load_regfile_fsm_load_store;
wire load_rs1_fsm_alu, load_rs1_fsm_branch_jump, load_rs1_fsm_load_store;
wire load_rs2_fsm_alu, load_rs2_fsm_branch_jump, load_rs2_fsm_load_store;
wire load_alu_fsm_alu, load_alu_fsm_branch_jump, load_alu_fsm_load_store;
wire load_imm_fsm_alu, load_imm_fsm_branch_jump, load_imm_fsm_load_store;
wire sel_alu_a_fsm_alu, sel_alu_a_fsm_branch_jump, sel_alu_a_fsm_load_store;
wire sel_alu_b_fsm_alu, sel_alu_b_fsm_branch_jump, sel_alu_b_fsm_load_store;
wire sub_sra_fsm_alu, sub_sra_fsm_branch_jump, sub_sra_fsm_load_store;

assign start_alu_fsm = code[12] & code[4] & code[5];
assign start_branch_jump_fsm = code[27] & code[25] & code[24];
assign start_load_store_fsm = code[13] & code[8] & code[0];

opdecoder opdecoder (
  .opcode (insn[6:0]),
  .code   (code)
);

fsm_alu fsm_alu (
    .insn             (insn),
    .code             (code), 
    .start            (start_alu_fsm), 
    .clk              (clk), 
    .lu               (lu), 
    .ls               (ls), 
    .eq               (eq), 
    .func3            (func3_fsm_alu), 
    .sel_rd           (sel_rd_fsm_alu), 
    .load_pc          (load_pc_fsm_alu),
    .load_ins         (load_ins_fsm_alu), 
    .load_regfile     (load_regfile_fsm_alu), 
    .load_rs1         (load_rs1_fsm_alu), 
    .load_rs2         (load_rs2_fsm_alu), 
    .load_alu         (load_alu_fsm_alu),
    .load_imm         (load_imm_fsm_alu),
    .load_flags       (load_flags_fsm_alu),
    .load_pc_alu      (load_pc_alu_fsm_alu), 
    .sel_pc_next      (sel_pc_next_fsm_alu), 
    .sel_pc_alu       (sel_pc_alu_fsm_alu), 
    .sel_alu_a        (sel_alu_a_fsm_alu), 
    .sel_alu_b        (sel_alu_b_fsm_alu), 
    .sub_sra          (sub_sra_fsm_alu),
    .load_data_memory (load_data_memory_fsm_alu),
    .write_mem        (write_mem_fsm_alu)
);

fsm_branch_jump fsm_branch_jump (
    .insn             (insn),
    .code             (code), 
    .start            (start_branch_jump_fsm), 
    .clk              (clk), 
    .lu               (lu), 
    .ls               (ls), 
    .eq               (eq), 
    .func3            (func3_fsm_branch_jump), 
    .sel_rd           (sel_rd_fsm_branch_jump), 
    .load_pc          (load_pc_fsm_branch_jump),
    .load_ins         (load_ins_fsm_branch_jump), 
    .load_regfile     (load_regfile_fsm_branch_jump), 
    .load_rs1         (load_rs1_fsm_branch_jump), 
    .load_rs2         (load_rs2_fsm_branch_jump), 
    .load_alu         (load_alu_fsm_branch_jump),
    .load_imm         (load_imm_fsm_branch_jump),
    .load_flags       (load_flags_fsm_branch_jump),
    .load_pc_alu      (load_pc_alu_fsm_branch_jump), 
    .sel_pc_next      (sel_pc_next_fsm_branch_jump), 
    .sel_pc_alu       (sel_pc_alu_fsm_branch_jump), 
    .sel_alu_a        (sel_alu_a_fsm_branch_jump), 
    .sel_alu_b        (sel_alu_b_fsm_branch_jump), 
    .sub_sra          (sub_sra_fsm_branch_jump),
    .load_data_memory (load_data_memory_fsm_branch_jump),
    .write_mem        (write_mem_fsm_branch_jump)
);

fsm_load_store fsm_load_store (
    .insn             (insn),
    .code             (code), 
    .start            (start_load_store_fsm), 
    .clk              (clk), 
    .lu               (lu), 
    .ls               (ls), 
    .eq               (eq), 
    .func3            (func3_fsm_load_store), 
    .sel_rd           (sel_rd_fsm_load_store), 
    .load_pc          (load_pc_fsm_load_store),
    .load_ins         (load_ins_fsm_load_store), 
    .load_regfile     (load_regfile_fsm_load_store), 
    .load_rs1         (load_rs1_fsm_load_store), 
    .load_rs2         (load_rs2_fsm_load_store), 
    .load_alu         (load_alu_fsm_load_store),
    .load_imm         (load_imm_fsm_load_store),
    .load_flags       (load_flags_fsm_load_store),
    .load_pc_alu      (load_pc_alu_fsm_load_store), 
    .sel_pc_next      (sel_pc_next_fsm_load_store), 
    .sel_pc_alu       (sel_pc_alu_fsm_load_store), 
    .sel_alu_a        (sel_alu_a_fsm_load_store), 
    .sel_alu_b        (sel_alu_b_fsm_load_store), 
    .sub_sra          (sub_sra_fsm_load_store),
    .load_data_memory (load_data_memory_fsm_load_store),
    .write_mem        (write_mem_fsm_load_store)
);

always @(*) begin
  if (start_alu_fsm) begin
    func3 = func3_fsm_alu;
    sel_rd = sel_rd_fsm_alu;
    load_pc = load_pc_fsm_alu;
    load_ins = load_ins_fsm_alu;
    load_regfile = load_regfile_fsm_alu;
    load_rs1 = load_rs1_fsm_alu;
    load_rs2 = load_rs2_fsm_alu;
    load_alu = load_alu_fsm_alu;
    load_imm = load_imm_fsm_alu;
    load_flags = load_flags_fsm_alu;
    load_pc_alu = load_pc_alu_fsm_alu;
    sel_pc_next = sel_pc_next_fsm_alu;
    sel_pc_alu = sel_pc_alu_fsm_alu;
    sel_alu_a = sel_alu_a_fsm_alu;
    sel_alu_b = sel_alu_b_fsm_alu;
    sub_sra = sub_sra_fsm_alu;
    load_data_memory = load_data_memory_fsm_alu;
    write_mem = write_mem_fsm_alu;
  end
  else if (start_branch_jump_fsm) begin
    func3 = func3_fsm_branch_jump;
    sel_rd = sel_rd_fsm_branch_jump;
    load_pc = load_pc_fsm_branch_jump;
    load_ins = load_ins_fsm_branch_jump;
    load_regfile = load_regfile_fsm_branch_jump;
    load_rs1 = load_rs1_fsm_branch_jump;
    load_rs2 = load_rs2_fsm_branch_jump;
    load_alu = load_alu_fsm_branch_jump;
    load_imm = load_imm_fsm_branch_jump;
    load_flags = load_flags_fsm_branch_jump;
    load_pc_alu = load_pc_alu_fsm_branch_jump;
    sel_pc_next = sel_pc_next_fsm_branch_jump;
    sel_pc_alu = sel_pc_alu_fsm_branch_jump;
    sel_alu_a = sel_alu_a_fsm_branch_jump;
    sel_alu_b = sel_alu_b_fsm_branch_jump;
    sub_sra = sub_sra_fsm_branch_jump;
    load_data_memory = load_data_memory_fsm_branch_jump;
    write_mem = write_mem_fsm_branch_jump;
  end
  else if (start_load_store_fsm) begin
    func3 = func3_fsm_load_store;
    sel_rd = sel_rd_fsm_load_store;
    load_pc = load_pc_fsm_load_store;
    load_ins = load_ins_fsm_load_store;
    load_regfile = load_regfile_fsm_load_store;
    load_rs1 = load_rs1_fsm_load_store;
    load_rs2 = load_rs2_fsm_load_store;
    load_alu = load_alu_fsm_load_store;
    load_imm = load_imm_fsm_load_store;
    load_flags = load_flags_fsm_load_store;
    load_pc_alu = load_pc_alu_fsm_load_store;
    sel_pc_next = sel_pc_next_fsm_load_store;
    sel_pc_alu = sel_pc_alu_fsm_load_store;
    sel_alu_a = sel_alu_a_fsm_load_store;
    sel_alu_b = sel_alu_b_fsm_load_store;
    sub_sra = sub_sra_fsm_load_store;
    load_data_memory = load_data_memory_fsm_load_store;
    write_mem = write_mem_fsm_load_store;
  end
  else begin
    func3 = 3'b000;
    sel_rd = 2'b00;
    load_pc = 1'b0;
    load_ins = 1'b0;
    load_regfile = 1'b0;
    load_rs1 = 1'b0;
    load_rs2 = 1'b0;
    load_alu = 1'b0;
    load_imm = 1'b0;
    load_flags = 1'b0;
    load_pc_alu = 1'b0;
    sel_pc_next = 1'b0;
    sel_pc_alu = 1'b0;
    sel_alu_a = 1'b0;
    sel_alu_b = 1'b0;
    sub_sra = 1'b0;
    load_data_memory = 1'b0;
    write_mem = 1'b0;
  end
end

assign rs1_addr = insn[19:15];
assign rs2_addr = insn[24:20];
assign rd_addr = insn[11:7];
assign sel_mem_extension = insn[14:12];
assign sel_mem_size = insn[13:12];
  
endmodule