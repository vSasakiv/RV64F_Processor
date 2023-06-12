module processor (
  input reset, start,
  input memory_done, //Retorna se acabou a operação da FSM do memory_management
  input clk,
  input [63:0] mem_i, //Valor carregado da memória 
  output sel_mem_operation, //Seleciona, no memory_management, entre load (se = 0) e store (se = 1)
  output [1:0] sel_mem_size, 
  output [2:0] sel_mem_extension,
  output memory_start, //inicia FSM do memory_management
  output [63:0] data_o, //Saída que vai para entrada de dados da memória
  output [63:0] addr //Endereço a ser lido/gravado na memória
);
  wire sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b, sel_alu_32b, sub_sra;
  wire load_data_memory, load_pc_alu, load_flags, load_pc, load_ins, load_regfile, load_rs1, load_rs2, load_alu, load_imm;
  wire sel_pc_increment, sel_pc_jump;
  wire [1:0] sel_rd;
  wire [2:0] flags_value, func3;
  wire [31:0] insn, code;
  wire [4:0] rs1_addr, rs2_addr, rd_addr;

  //***Sinais novos q saem da CU
  wire sel_mem_next; //Seleciona se o próximo endereço da memória é alu_value ou pc_value


  //***Outros sinais
  wire [7:0] mem_o; //Saída da memória
  wire [7:0] data_mem; //Entrada da memória
  wire [63:0] mem_addr; // Endereço da memória


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
    .sel_pc_increment (sel_pc_increment),
    .sel_pc_jump      (sel_pc_jump), 
    .sel_alu_32b      (sel_alu_32b),
    .load_data_memory (load_data_memory), 
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
    .sub_sra          (sub_sra),
    .start            (start),
    .memory_start     (memory_start),
    .memory_done      (memory_done),
    .sel_mem_operation(sel_mem_operation),
    .sel_mem_next     (sel_mem_next)

  );

  dataflow DP (
    .clk              (clk),
    .sub_sra          (sub_sra),
    .reset            (reset),
    .sel_pc_next      (sel_pc_next),
    .sel_pc_increment (sel_pc_increment),
    .sel_pc_jump      (sel_pc_jump), 
    .sel_alu_a        (sel_alu_a), 
    .sel_alu_b        (sel_alu_b),
    .sel_alu_32b      (sel_alu_32b),
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
    .func3            (func3),
    .sel_mem_extension(sel_mem_extension),
    .rd_addr          (rd_addr), 
    .rs1_addr         (rs1_addr), 
    .rs2_addr         (rs2_addr),
    .code             (code),
    .insn             (insn),
    .sel_mem_next     (sel_mem_next),
    .mem_i            (mem_i),
    .flags_value      (flags_value),
    .rs2_value_o      (data_o),
    .addr             (addr)
  );

endmodule