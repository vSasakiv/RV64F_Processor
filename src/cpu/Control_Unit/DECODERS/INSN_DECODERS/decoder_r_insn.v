/* Módulo para decodificação de instruções do tipo R de acordo com
o ISA do risc-v. O módulo recebe a instrução e retorna todas as saídas relevantes a serem enviadas ao circuito */
module decoder_r_insn (
  input wire [31:0] insn, // instrução de 32 bits
  output wire sub_sra // controle de adição/subtração e de logical/arithmetic shift
);

  assign sub_sra = ((~insn[14]) & insn[13]) | insn[30]; 
  // Está codificada no segundo bit mais signifcativo da instrução, e também deverá ser 1 caso a instrução necessite de uma comparação

endmodule