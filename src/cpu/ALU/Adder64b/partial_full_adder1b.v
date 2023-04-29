/* Partial Adder, recebe dois números de 1 bit, A e B, e um carry in CIN.
Suas saídas são:
S - Soma (A ^ B ^ CIN)
P - Propagate, verifica se A e B propagam um carry. 1 caso propaga, 0 caso contrário. (A | N) 
G - Generate, verifica se A e B geram um carry. 1 caso gere, 0 caso contrário (A & B) */
module partial_full_adder1b (
    input a, b, c_i,
    output s, p, g
);
wire w1;

    xor U1 (w1, a, b);
    xor U2 (s, w1, c_i);
    or U3 (p, a, b);
    and U4 (g, a, b);

endmodule