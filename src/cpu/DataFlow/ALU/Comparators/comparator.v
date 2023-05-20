/* 
Módulo que junta todos os 3 comparadores feitos
em um único módulo 
*/
module comparator (
  input wire a_sign, b_sign, c_o, // Bit de sinal de a e a, e o bit c_o (carry out)
  input wire [63:0] s, // Valor da subtração A - B
  output wire eq, lu, ls // Saídas das comparações
);
  
  // Utilização dos módulos previamente criados
  comparator_eq E0 (.s, .eq);
  comparator_lt_unsigned CU0 (.c_o, .eq, .lu);
  comparator_lt_signed CS0 (.a_sign, .b_sign, .s_sign(s[63]), .eq, .ls);

endmodule
