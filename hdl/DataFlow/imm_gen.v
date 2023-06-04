/* Módulo responsável por fornecer o valor do imediato codificado na instrução.
Para cada tipo de instrução (cada opcode), codificado no sinal "code", 
o módulo monta o valor do imediato a partir da instrução insn de acordo com a ISA do risc-v. */
module imm_gen (
  input [31:0] insn, // Instrução 
  input [31:0] code, // Código gerado pelo OPDecoder, codifica o opcode
  output [63:0] imm // Valor do imediato
);

  wire [63:0] type_j, type_i, type_u, type_b, type_s;
  
  assign type_j = {{44{insn[31]}}, insn[19:12], insn[20], insn[30:21], 1'b0}; //Imediato do tipo UJ
  assign type_i = {{52{insn[31]}}, insn[31:20]}; //Imediato do tipo I
  assign type_u = {{32{insn[31]}}, insn[31:12], 12'b0}; //Imediato do tipo U
  assign type_b = {{52{insn[31]}}, insn[7], insn[30:25], insn[11:8], 1'b0}; //Imediato do tipo SB
  assign type_s = {{52{insn[31]}}, insn[31:25], insn[11:7]}; //Imediato do tipo S

  /* Como "code" também indica o tipo de instrução, 
  só passará para a saída o valor do imediato do mesmo tipo que ela */
  assign imm = (type_j & {64{code[27]}}) | 
               (type_i & {64{(code[0] | code[4] | code[6] |code[25] | code[28])}}) | 
               (type_u & {64{(code[5] | code[13])}}) |
               (type_b & {64{code[24]}}) |
               (type_s & {64{code[8]}});  

endmodule