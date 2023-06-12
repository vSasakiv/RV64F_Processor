/* Módulo que representa um multiplexador parametrizáel de 4 entradas de "Size" bits */
module mux_4to1 #(
    parameter Size = 64 
) (
  input [1:0] sel, // seletor do multiplexador
  input [Size - 1:0] i0, i1, i2, i3, // entradas
  output reg [Size - 1:0] data_o // saída
);

  //Com base no seletor "sel", escolhe qual valor de entra será direcionado para a saída data_o
  always @(*) begin
    case (sel)
      2'b00: data_o = i0; 
      2'b01: data_o = i1; 
      2'b10: data_o = i2; 
      2'b11: data_o = i3; 
    endcase
  end

endmodule