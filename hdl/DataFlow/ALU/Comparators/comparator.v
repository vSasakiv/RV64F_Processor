/* 
  Módulo compardor
*/
module comparator (
  input wire [63:0] a, b, // Valores de entrada a e b
  output wire eq, lu, ls // Saídas das comparações
);

  // Especifica valores signed e unsigned para as entradas
  wire unsigned [63:0] a_u, b_u;
  wire signed [63:0] a_s, b_s;
  
  assign a_u = a;
  assign a_s = a;
  assign b_u = b;
  assign b_s = b;
  
  // Retornas as comparações
  assign eq = (a == b);
  assign lu = (a_u < b_u);
  assign ls = (a_s < b_s);

endmodule
