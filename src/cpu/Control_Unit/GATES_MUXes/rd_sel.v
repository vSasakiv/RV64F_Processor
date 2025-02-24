/* Módulo responsável por gerar o sinal rd_sel a partir do código code:
Code = 10'b0000000001, gera sinal: 11 // Instrução tipo J 
Code = 10'b0000000010, gera sinal: 11 // Instrução tipo I (Jarl)
Code = 10'b0000000100, gera sinal: 01 // Instrução tipo U (LUI)
Code = 10'b0000001000, gera sinal: 10 // Instrução tipo U (AUIPC)
Code = 10'b0000010000, gera sinal: xx // Instrução tipo B
Code = 10'b0000100000, gera sinal: 10 // Instrução tipo R
Code = 10'b0001000000, gera sinal: xx // Instrução tipo S
Code = 10'b0010000000, gera sinal: 10 // Instrução tipo I (ALU)
Code = 10'b0100000000, gera sinal: 00 // Instrução tipo I (LOAD)
Code = 10'b1000000000, gera sinal: xx // Instrução tipo I (CSR)

Tabela verdade do circuito (função em mintermos no output a direita e maxtermos no output a esquerda, com A sendo msb e J lsb):

    0000000001  1 / 1                        / (~A&~B&~C&~D&~E&~F&~G&~H&~I&J)
    0000000010  1 / 1                        / (~A&~B&~C&~D&~E&~F&~G&~H&I&~J)
    0000000100  0 / 1 (A|B|C|D|E|F|G|~H|I|J) / (~A&~B&~C&~D&~E&~F&~G&H&~I&~J)
    0000001000  1 / 0
    0000010000  x / x
    0000100000  1 / 0
    0001000000  x / x
    0010000000  1 / 0
    0100000000  0 / 0 (A|~B|C|D|E|F|G|H|I|J)
    1000000000  x / x
Função (output direita) = (~A&~B&~C&~D&~E&~F&~G&~H&~I&J) | (~A&~B&~C&~D&~E&~F&~G&~H&I&~J) | (~A&~B&~C&~D&~E&~F&~G&H&~I&~J)
Função (output esquerda) = (A|B|C|D|E|F|G|~H|I|J) & (A|~B|C|D|E|F|G|H|I|J)
*/

module rd_sel (code, rd_sel);
input [9:0] code;
output [1:0] rd_sel;

    // Assign com expressão derivada das expressões
    assign rd_sel[1] = (code[9]|~code[8]|code[7]|code[6]|code[5]|code[4]|code[3]|code[2]|code[1]|code[0]) & (code[9]|code[8]|code[7]|code[6]|code[5]|code[4]|code[3]|~code[2]|code[1]|code[0]);
    assign rd_sel[0] = (~code[9] & ~code[8] & ~code[7] & ~code[6] & ~code[5] & ~code[4] & ~code[3] & ~code[2] & ~code[1] & code[0]) | (~code[9] & ~code[8] & ~code[7] & ~code[6] & ~code[5] & ~code[4] & ~code[3] & ~code[2] & code[1] & ~code[0]) | (~code[9] & ~code[8] & ~code[7] & ~code[6] & ~code[5] & ~code[4] & ~code[3] & code[2] & ~code[1] & ~code[0]);
endmodule
