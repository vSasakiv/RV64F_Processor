module cpu (
  input reset
);
  wire clk;
  wire write_mem, sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b, sub_sra;
  wire load_data_memory, load_pc_alu, load_flags, load_pc, load_ins, load_regfile, load_rs1, load_rs2, load_alu, load_imm;
  wire [1:0] sel_rd, sel_mem_size;
  wire [2:0] flags_value, func3, sel_mem_extension;
  wire [31:0] insn, code;
  wire [4:0] rs1_addr, rs2_addr, rd_addr;

  clock_gen clk_gen (
    .clk(clk)
  );

  control_unit CU (
    .insn             (insn),
    .clk              (clk), 
    .reset            (reset),
    .lu               (flags_value[2]), 
    .ls               (flags_value[1]), 
    .eq               (flags_value[0]), 
    .code             (code),
    .rs1_addr         (rs1_addr), 
    .rs2_addr         (rs2_addr), 
    .rd_addr          (rd_addr),
    .func3            (func3),
    .sel_mem_extension(sel_mem_extension),
    .sel_rd           (sel_rd),
    .sel_mem_size     (sel_mem_size),
    .sel_pc_next      (sel_pc_next), 
    .sel_pc_alu       (sel_pc_alu), 
    .load_data_memory (load_data_memory), 
    .write_mem        (write_mem), 
    .load_pc_alu      (load_pc_alu), 
    .load_flags       (load_flags),
    .load_pc          (load_pc), 
    .load_ins         (load_ins), 
    .load_regfile     (load_regfile), 
    .load_rs1         (load_rs1), 
    .load_rs2         (load_rs2), 
    .load_alu         (load_alu), 
    .load_imm         (load_imm),
    .sel_alu_a        (sel_alu_a), 
    .sel_alu_b        (sel_alu_b), 
    .sub_sra          (sub_sra) 
  );

  dataflow DP (
    .clk              (clk),
    .sub_sra          (sub_sra),
    .write_mem        (write_mem),
    .reset            (reset),
    .sel_pc_next      (sel_pc_next), 
    .sel_pc_alu       (sel_pc_alu), 
    .sel_alu_a        (sel_alu_a), 
    .sel_alu_b        (sel_alu_b),
    .load_ins         (load_ins), 
    .load_imm         (load_imm), 
    .load_regfile     (load_regfile), 
    .load_pc          (load_pc), 
    .load_rs1         (load_rs1), 
    .load_rs2         (load_rs2), 
    .load_alu         (load_alu), 
    .load_flags       (load_flags),
    .load_pc_alu      (load_pc_alu), 
    .load_data_memory (load_data_memory),
    .sel_rd           (sel_rd), 
    .sel_mem_size     (sel_mem_size),
    .func3            (func3),
    .sel_mem_extension(sel_mem_extension),
    .rd_addr          (rd_addr), 
    .rs1_addr         (rs1_addr), 
    .rs2_addr         (rs2_addr),
    .code             (code),
    .flags_value      (flags_value),
    .insn             (insn)
  );


endmodule