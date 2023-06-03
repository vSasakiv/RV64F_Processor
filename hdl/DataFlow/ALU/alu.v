/* 
Módulo da Unidade Lógica Aritmética (ALU) do processador
Este módulo contém uma conglomeração de todos os módulos
de circuitos combinatórios aritméticos e comparadores
*/
module alu (
  input [63:0] a, b, // Entradas A e B da ALU, sendo A o primeiro operando e B o segundo
  input [2:0] func, // Entrada seletora de func proveniente da C.U.
  input sub_sra, // Entrada que ativa / desativa subtração e shift aritmético
  output reg [63:0] s, // Saída, que é selecionada pela entrada func
  output wire eq, ls, lu  // Saídas de comparador, são sempre expostas para a C.U.
);
  
  wire [63:0] add, b_xor, b_and, b_or, shift_right, shift_left; // Guardam valores de possíveis operações que podem ser selecionados pelo func
  wire c_o; // Fio que contém o carry out da soma / subtração
  
  adder64b a0 (.a(a), .b(b), .s(add), .sub(sub_sra), .c_o(c_o)); // Módulo de soma
  and64b band0 (.a(a), .b(b), .s(b_and)); // Módulo and bitwise
  or64b bor0 (.a(a), .b(b), .s(b_or)); // Módulo or bitwise
  xor64b bxor0 (.a(a), .b(b), .s(b_xor)); // Módulo xor bitwise
  left_lshifter lefts0 (.a(a), .b(b), .s(shift_left)); // Módulo barrel left shifter
  right_shifter rights0 (.a(a), .b(b), .sra(sub_sra), .s(shift_right)); // Módulo barrel right shifter
  comparator c0 (.a_sign(a[63]), .b_sign(b[63]), .s(add), .c_o(c_o), .eq(eq), .ls(ls), .lu(lu));
  // módulo comparadores (só funciona quando sub_sra = 1)

  // Bloco always para síntese de multiplexador para selecionar as saídas
  always @(*) begin
    // Case baseado nas instruções presentes na ISA, para poupar o máximo da C.U.
    case (func)
      3'b000: s = add;
      3'b001: s = shift_left;
      3'b010: s = ls;
      3'b011: s = lu;
      3'b100: s = b_xor;
      3'b101: s = shift_right;
      3'b110: s = b_or;
      3'b111: s = b_and;
    endcase
  end

endmodule
