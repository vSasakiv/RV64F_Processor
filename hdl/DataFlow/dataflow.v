/* Módulo que contém a junção de todos os módulos pertecentes ao dataflow */
module dataflow (
  input clk,
  input sub_sra,
  input reset,
  input sel_pc_next, sel_pc_increment, sel_pc_jump, sel_alu_a, sel_alu_b, sel_mem_next, sel_alu_32b,
  input load_ins, load_imm, load_regfile, load_pc, load_rs1, load_rs2, load_alu, load_pc_alu, load_data_memory, load_flags,
  input [1:0] sel_rd,
  input [2:0] func3,
  input [2:0] sel_mem_extension,
  input [4:0] rd_addr, rs1_addr, rs2_addr,
  input [31:0] code,
  input [63:0] mem_i,
  output [2:0] flags_value,
  output [31:0] insn,
  output [63:0] addr, rs2_value_o
);
  wire eq, ls, lu;
  wire [31:0] insn_value;
  wire [63:0] imm_o, imm_value;
  wire [63:0] alu_o, alu_value, alu_value_extended;
  wire [63:0] alu_a_value, alu_b_value;
  wire [63:0] mem_extended, mem_value;
  wire [63:0] rd_i, rs1_o, rs2_o, rs1_value, rs2_value;
  wire [63:0] pc_alu_o, pc_alu_value, pc_selected, pc_alu_selected, pc_value;

  assign rs2_value_o = rs2_value;
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

  //Registrador que guarda a saída da memória de dados
  register #(.Size(64)) reg_data_mem (
    .clk   (clk),
    .load  (load_data_memory),
    .data_i(mem_i),
    .data_o(mem_value)
  );

  //Registrador que guarda a saída da alu do program counter
  register #(.Size(64)) pc_alu (
    .clk   (clk),
    .load  (load_pc_alu),
    .data_i(pc_alu_o),
    .data_o(pc_alu_value)
  );

  //Módulo que contem o registrador program counter e todos os seus componentes auxiliares,
  //Como somadores e multiplexadores
  program_counter PC (
    .clk              (clk),
    .load_pc          (load_pc),
    .reset            (reset),
    .sel_pc_increment (sel_pc_increment),
    .sel_pc_next      (sel_pc_next),
    .sel_pc_jump      (sel_pc_jump),
    .rs1_value        (rs1_value),
    .imm_value        (imm_value),
    .pc_value         (pc_value),
    .pc_alu_o         (pc_alu_o)
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
    .data_i(mem_i[31:0]),
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
    .data_i({lu, ls, eq}),
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

 //Multiplexador para selecionar o endereço a ser acessado na memória
  mux_2to1 #(.Size(64)) mux_pc_addr  (
    .sel   (sel_mem_next),
    .i0    (pc_value),
    .i1    (alu_value),
    .data_o(addr)
  );

  mux_2to1 #(.Size(64)) mux_alu_out (
    .sel(sel_alu_32b),
    .i0(alu_value),
    .i1({{32{alu_value[31]}}, alu_value[31:0]}),
    .data_o(alu_value_extended)
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
    .i2    (alu_value_extended),
    .i3    (pc_alu_value),
    .data_o(rd_i)  
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