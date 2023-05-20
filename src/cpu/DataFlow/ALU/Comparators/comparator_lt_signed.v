/* 
Módulo para realização de comparação entre dois números
signed A e B, devolvendo ls = 1, caso A < B,
dados os bits de sinal de A e B e da subtração,
além do sinal de igualdade
 */
module comparator_lt_signed (
  input wire a_sign, b_sign, s_sign, eq, // Entradas de sinal e igualdade
  output wire ls // Saída
);

  assign ls = (a_sign & ~b_sign) | (~eq & s_sign) & (~b_sign | a_sign); // Expressão lógica derivada de tabela verdade

endmodule