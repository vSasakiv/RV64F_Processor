/* Módulo OR de 32 bits.
Faz um bitwise OR entre dois valores de 32 bits, A e B.
Resultado vai para saída O. */
module or64b (
    input [63:0] a, b,
    output [63:0] s
);
    assign s = a | b;

endmodule