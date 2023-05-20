/* Módulo que contém a junção de todos os módulos pertecentes ao dataflow */
module dataflow (
  input clk,
  input sub_sra,
  input write_mem,
  input reset,
  input sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b,
  input load_ins, load_imm, load_regfile, load_pc, load_rs1, load_rs2, load_alu, load_pc_alu, load_data_memory,
  input [1:0] sel_rd, sel_mem_size,
  input [2:0] func3,
  input [2:0] sel_mem_extension,
  input [4:0] rd_addr, rs1_addr, rs2_addr,
  input [31:0] code,
  output [2:0] flags_value,
  output [31:0] insn
);
  wire eq, ls, lu;
  wire [31:0] insn_o, insn_value;
  wire [63:0] imm_o, imm_value;
  wire [63:0] alu_o, alu_value;
  wire [63:0] alu_a_value, alu_b_value;
  wire [63:0] mem_extended, mem_o, mem_value;
  wire [63:0] rd_i, rs1_o, rs2_o, rs1_value, rs2_value;
  wire [63:0] pc_alu_o, pc_alu_value, pc_selected, pc_alu_selected, pc_value;

  assign insn = insn_value;
  
  //Módulo memory extender, utilizado para corrigir o valor que será carregado em um registrador do regfile, de acordo com a instrução
  mem_extension mem_ex (
    .sel_mem_extension(sel_mem_extension),
    .mem_value        (mem_value),
    .mem_extended     (mem_extended)
  );

  //Módulo que forma o valor do imediato a partir da instrução 
  imm_gen imm_gen (
    .insn(insn_value),
    .code(code),
    .imm (imm_o)
  );

  //Memória de instruções
  insn_memory insn_mem (
    .addr(pc_value),
    .insn(insn_o)
  );

  //Memória de dados
  data_memory data_mem (
    .clk         (clk),
    .write       (write_mem),
    .sel_mem_size(sel_mem_size),
    .data_i      (rs2_value),
    .data_o      (mem_o),
    .addr        (alu_value)
  );

  //Registrador para o Program Counter (PC)
  reg_async_reset #(.Size(64)) pc (
    .clk   (clk),
    .reset (reset),
    .load  (load_pc),
    .data_i(pc_selected),
    .data_o(pc_value)
  );

  //Registrador que guarda a saída da memória de dados
  register #(.Size(64)) reg_data_mem (
    .clk   (clk),
    .load  (load_data_memory),
    .data_i(mem_o),
    .data_o(mem_value)
  );

  //Registrador que guarda a saída da alu do program counter
  register #(.Size(64)) pc_alu (
    .clk   (clk),
    .load  (load_pc_alu),
    .data_i(pc_alu_o),
    .data_o(pc_alu_value)
  );

  //Registrador que guarda o imm 
  register #(.Size(64)) reg_imm (
    .clk   (clk),
    .load  (load_imm),
    .data_i(imm_o),
    .data_o(imm_value)
  );

  //Registrador que contém as instruções sendo atualmente executadas
  register #(.Size(32)) ir (
    .clk   (clk),
    .load  (load_ins),
    .data_i(insn_o),
    .data_o(insn_value)
  );

  //Registrador que guarda a saída rs1 do regfile
  register #(.Size(64)) reg_alu_a (
    .clk   (clk),
    .load  (load_rs1),
    .data_i(rs1_o),
    .data_o(rs1_value)
  );

  //Registrador que guarda a saída rs2 do regfile
  register #(.Size(64)) reg_alu_b (
    .clk   (clk),
    .load  (load_rs2),
    .data_i(rs2_o),
    .data_o(rs2_value)
  );

  //Registrador que guarda a saída da ALU
  register #(.Size(64)) reg_alu_o (
    .clk   (clk),
    .load  (load_alu),
    .data_i(alu_o),
    .data_o(alu_value)
  );

  //Registrador que guarda as flags obtidas da ALU
  register #(.Size(3)) reg_flags (
    .clk   (clk),
    .load  (load_flags),
    .data_i({eq, ls, lu}),
    .data_o({flags_value})
  );

  //Regfile
  regfile #(.Size(64)) regfile (
    .clk     (clk),
    .load    (load_regfile),
    .rd_addr (rd_addr),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_i    (rd_i),
    .rs1_o   (rs1_o),
    .rs2_o   (rs2_o)
  );

  //Multiplexador para selecionar o próximo valor do PC
  mux_2to1 #(.Size(64)) mux_pc_next  (
    .sel   (sel_pc_next),
    .i0    (pc_alu_o),
    .i1    (alu_value),
    .data_o(pc_selected)
  );

  // multiplexador para seleção da segunda entrada da ALU do Program Counter
  mux_2to1  #(.Size(64)) mux_pc_alu (
    .sel   (sel_pc_alu),
    .i0    (64'h00000004),
    .i1    (imm_value),
    .data_o(pc_alu_selected)  
  );

  // multiplexador para selecionar qual valor irá entrar na ALU geral, podendo ser o PC ou o valor do rs1
  mux_2to1 #(.Size(64)) mux_alu_a (
    .sel   (sel_alu_a),
    .i0    (rs1_value),
    .i1    (pc_value),
    .data_o(alu_a_value) 
  );

  // multiplexador para selecionar qual valor irá entrar na ALU geral, podendo ser um imediato ou o valor do rs2
  mux_2to1 #(.Size(64)) mux_alu_b (
    .sel   (sel_alu_b),
    .i0    (rs2_value),
    .i1    (imm_value),
    .data_o(alu_b_value) 
  );

  // multiplexador para selecionar qual valor deverá ser gravado no registrador destino presente na Regfile
  mux_4to1 #(.Size(64)) mux_rd (
    .sel   (sel_rd),
    .i0    (mem_extended),
    .i1    (imm_value),
    .i2    (alu_value),
    .i3    (pc_alu_value),
    .data_o(rd_i)  
  );
  
  // ALU do Program Counter, neste caso sendo apenas um somador de 64bits.
  adder64b pc_adder (
    .a  (pc_value),
    .b  (pc_alu_selected),
    .sub(1'b0),
    .s  (pc_alu_o)
  );

  // ALU
  alu alu (
    .a      (alu_a_value),
    .b      (alu_b_value),
    .func   (func3),
    .sub_sra(sub_sra),
    .s      (alu_o),
    .eq     (eq),
    .lu     (lu),
    .ls     (ls)
  ); 

endmodule