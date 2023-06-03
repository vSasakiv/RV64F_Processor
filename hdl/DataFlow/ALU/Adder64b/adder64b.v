/* Módulo responsável por adicionar dois números de 64 bits, a e b.
A soma sai na saída S e o carry out dela no c_o.
O sinal sub, quando igual a 1, indica que será realizada uma operação de subtração (a - b)
Na subtração, é usado o complemento de 2, complementando b e somando 1 (diretamente no carry-in da primeira soma)

Somador composto por 8 módulos de Carry Look-Ahead Adders de 8 bits cada, totalizando 64 bits.
*/
module adder64b (
  input [63:0] a, b,
  input sub,
  output c_o,
  output [63:0] s
);
  wire [63:0] c;
  wire c1, c2, c3, c4, c5, c6, c7;

  /* XOR entre cada bit de b e o sub, responsável por complementar b caso sub = 1*/
  assign c = b ^ {64{sub}};

  /* Sequencia de Carry Look-Ahead Adders de 8 bits, interligados de modo Ripple Carry */
  cla_adder8b u7_0 (.a(a[7:0]), .b(c[7:0]), .c_i(sub), .s(s[7:0]), .c_o(c1)); // Sinal sub ligado diretamente no c_i (carry in), para somar 1 do 2's complement caso sub = 1 
  cla_adder8b u15_8 (.a(a[15:8]), .b(c[15:8]), .c_i(c1), .s(s[15:8]), .c_o(c2));
  cla_adder8b u23_16 (.a(a[23:16]), .b(c[23:16]), .c_i(c2), .s(s[23:16]), .c_o(c3));
  cla_adder8b u31_24 (.a(a[31:24]), .b(c[31:24]), .c_i(c3), .s(s[31:24]), .c_o(c4));
  cla_adder8b u39_32 (.a(a[39:32]), .b(c[39:32]), .c_i(c4), .s(s[39:32]), .c_o(c5)); 
  cla_adder8b u47_40 (.a(a[47:40]), .b(c[47:40]), .c_i(c5), .s(s[47:40]), .c_o(c6));
  cla_adder8b u55_48 (.a(a[55:48]), .b(c[55:48]), .c_i(c6), .s(s[55:48]), .c_o(c7));
  cla_adder8b u63_56 (.a(a[63:56]), .b(c[63:56]), .c_i(c7), .s(s[63:56]), .c_o(c_o));
  
endmodule