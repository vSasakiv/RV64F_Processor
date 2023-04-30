/* 
Módulo para realização de comparação entre dois números
unsigned A e B, devolvendo lu = 1 caso A < B,
dados o Carry out da soma pelo complemento de dois
do segundo (subtração) e a igualdade.
 */
module comparator_lt_unsigned (
  input wire c_o, eq, // Entradas c_o (carry out) e eq (igualdade)
  output wire lu 
);

  assign lu = ~(c_o | eq); // Expressão lógica derivada de tabela verdade
  
endmodule
