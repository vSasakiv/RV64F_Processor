/* Módulo que representa um multiplexador parametrizáel de 2 entradas de "Size" bits */
module mux_2to1 #(
    parameter Size = 64 
) (
  input sel, // entrada que seleciona qual das duas entradas deve passar para a saída
  input [Size - 1:0] i0, i1, // valores de entrada
  output [Size - 1:0] data_o // valores de saída
);
  // sel = 1 -> saída = i1
  // sel = 0 -> saída = i0
  assign data_o = sel ? i1 : i0;

endmodule