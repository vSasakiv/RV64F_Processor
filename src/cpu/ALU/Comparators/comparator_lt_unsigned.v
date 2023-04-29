/* 
Módulo para realização de comparação entre dois números
unsigned A e B, devolvendo R = 1 caso A < B,
dados o Carry out da soma pelo complemento de dois
do segundo (subtração) e a igualdade.
 */
module comparator_lt_unsigned (
  input wire c_o, eq, // Entradas COUT e igualdade
  output wire lu // Saída
);

  assign lu = ~(c_o | eq); // Expressão lógica derivada de tabela verdade
  
endmodule