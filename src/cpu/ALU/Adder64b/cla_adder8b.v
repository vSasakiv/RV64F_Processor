/* Módulo do somador Carry Look-Ahead de 8bits.
Recebe dois números de 8 bits, A e B e um carry in CIN e devolve a soma A + B no S, assim como o carry out dela no COUT.
O somador carry look ahead calcula os carries fazendo 
Ci = Gi + Pi*Ci-1 
sendo:
    Gi = Ai * Bi (generate, verifica se Ai e Bi geram um carry)
    Pi =  Ai + Bi (propagate, verifica se Ai e Bi propagam um carry)
    Ci-1 = carry anterior

cada carry i é somado com os bits Ai e Bi no somador parcial de um bit (PartialFullAdder1b)
*/

module cla_adder8b(
    input [7:0] a, b, // entradas
    input c_i, // carry-in
    output c_o, // carry-out
    output [7:0] s
  );

    wire c1, c2, c3, c4, c5, c6, c7;
    wire p0, p1, p2, p3, p4, p5, p6, p7;
    wire pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8;
    wire g1, g2, g3, g4, g5, g6, g7, g8;
    
    // C1 = G1 + P1*C0 (C0 = CIN) 
    and p01 (pc1, p0, c_i);
    or c01 (c1, g1, pc1);

    // C2 = G2 + P2*C1 
    and p02 (pc2, p1, c1);
    or c02 (c2, g2, pc2);

    // C3 = G3 + P3*C2 
    and p03 (pc3, p2, c2);
    or c03 (c3, g3, pc3);

    // C4 = G4 + P4*C3 
    and p04 (pc4, p3, c3);
    or c04 (c4, g4, pc4);

    // C5 = G5 + P5*C4 
    and p05 (pc5, p4, c4);
    or c05 (c5, g5, pc5);

    // C6 = G6 + P6*C5 
    and p06 (pc6, p5, c5);
    or c06 (c6, g6, pc6);

    // C7 = G7 + P7*C6 
    and p07 (pc7, p6, c6);
    or c07 (c7, g7, pc7);

    // C8 = G8 + P8*C7 
    and p08 (pc8, p7, c7);
    or c08 (c_o, g8, pc8);

    //Sequencia de Partial Full Adders, um para cada bit de A e B
    partial_full_adder1b u0 (.a(a[0]), .b(b[0]), .c_i, .s(s[0]), .p(p0), .g(g1));
    partial_full_adder1b u1 (.a(a[1]), .b(b[1]), .c_i(c1), .s(s[1]), .p(p1), .g(g2));
    partial_full_adder1b u2 (.a(a[2]), .b(b[2]), .c_i(c2), .s(s[2]), .p(p2), .g(g3));
    partial_full_adder1b u3 (.a(a[3]), .b(b[3]), .c_i(c3), .s(s[3]), .p(p3), .g(g4));
    partial_full_adder1b u4 (.a(a[4]), .b(b[4]), .c_i(c4), .s(s[4]), .p(p4), .g(g5));
    partial_full_adder1b u5 (.a(a[5]), .b(b[5]), .c_i(c5), .s(s[5]), .p(p5), .g(g6));
    partial_full_adder1b u6 (.a(a[6]), .b(b[6]), .c_i(c6), .s(s[6]), .p(p6), .g(g7));
    partial_full_adder1b u7 (.a(a[7]), .b(b[7]), .c_i(c7), .s(s[7]), .p(p7), .g(g8));

endmodule