/* 
Módulo responsável por verificar a igualdade entre duas entradas,
dada o resultado da subtração (S) entre as duas
*/
module comparator_eq (
  input wire [63:0] s, // Subtração de A por B
  output wire eq // Saída resultado
);
  
  assign eq = ~(|s); // NOR de 32 entradas, realizada com cada um dos bits
// Caso um único bit seja 1, a saída já será 0.

endmodule 