/* Módulo OR de 64 bits.
Faz um bitwise OR entre dois valores de 64 bits, A e B.
Resultado vai para saída s. */
module or64b (
    input [63:0] a, b,
    output [63:0] s
);
    assign s = a | b;

endmodule