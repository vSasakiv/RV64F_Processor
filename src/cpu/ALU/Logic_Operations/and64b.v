/* Módulo AND de 32 bits.
Faz um bitwise AND entre dois valores de 32 bits, A e B.
Resultado vai para saída And. */
module and64b (
    input [63:0] a, b,
    output [63:0] s
);
    assign s = a & b;

endmodule 