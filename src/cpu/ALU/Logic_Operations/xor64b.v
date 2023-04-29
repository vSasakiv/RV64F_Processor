/* Módulo XOR de 32 bits.
Faz um bitwise XOR entre dois valores de 32 bits, A e B.
Resultado vai para saída Xor. */
module xor64b (
    input [63:0] a, b,
    output [63:0] s
);
    assign s = a ^ b;

endmodule 