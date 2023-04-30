/* Módulo responsável pela operação Left Logical Shift 
Recebe um número de 64 bits A e shifta ele para esquerda na quantidade especificada pelos 6 LSB de B */
module left_lshifter ( 
    input [63:0] a, b,
    output [63:0] s
    );
    
    assign s = a << b[5:0];

endmodule