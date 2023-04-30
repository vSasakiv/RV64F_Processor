/* Módulo responsável por dar Right Logical Shift ou Right Arithmetic Shift
Recebe dois números de 64 bits, A e B, e shifta A para direita na quantidade especificada pelos 6 LSB de B.
Resultado é atribuido na saída Shifted.
Caso SRA for 1, executa um arithmetic shift, caso contrário (igual a 0) executa um logical shift */
module right_shifter (
    input signed [63:0] a, b,
    input sra,
    output reg [63:0] s
);
    always @ (a, b, sra)
        if (sra == 1'b0) s = a >> b[5:0];
        else s = a >>> b[5:0];

endmodule