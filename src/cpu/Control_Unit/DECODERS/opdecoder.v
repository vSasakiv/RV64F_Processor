/*
Módulo responsável por decodificar o OPCODE retirado de uma instrução de 32bits
Decodifica os dois bits mais significativos - 6 e 5 - e separa os OPCODEs em 4 grupos 
Após isso, decodifica os próximos 3 bits - 4, 3 e 2- separando os OPCODEs em 8 grupos 
esses grupos são combinados de forma a formar 32 "grupos" por meio de portas ANDs, cada com um <=1 OPCODE.

Os resultados são direcionados na saída code, 
sendo que o bit de code será 1 somente na posição que corresponder ao "grupo" da OPCODE.
A posição desse bit para um opcode é 8 * i + j, sendo i = opcode[6:5] e j = opcode[4:2]

Exemplo:
  OPCODE:
  7'b01_011_11 - Type R (AMO)
  posição do bit 1 em code: (3'd8 * 2'b01) + 3'b011 = 4'b1011 = 4'd11
  ou seja
  code = 32'b100000000000; 
  code[11] = 1;

Segue abaixo, para fins de consulta, a posição do bit no code para cada OPCODE:
  code[00] = 1'b1; ---------> opcode = 7'b00_000_11 - Type I  (LOAD) 
  code[01] = 1'b1; ---------> opcode = 7'b00_001_11 - Type I  (LOAD-FP)
  code[03] = 1'b1; ---------> opcode = 7'b00_011_11 - Type I  (MISC-MEM)
  code[04] = 1'b1; ---------> opcode = 7'b00_100_11 - Type I  (OP-IMM)
  code[05] = 1'b1; ---------> opcode = 7'b00_101_11 - Type U  (AUIPC)
  code[06] = 1'b1; ---------> opcode = 7'b00_110_11 - Type I  (OP-IMM-32)
  code[08] = 1'b1; ---------> opcode = 7'b01_000_11 - Type S  (STORE)
  code[09] = 1'b1; ---------> opcode = 7'b01_001_11 - Type S  (STORE-FP)
  code[11] = 1'b1; ---------> opcode = 7'b01_011_11 - Type R  (AMO)
  code[12] = 1'b1; ---------> opcode = 7'b01_100_11 - Type R  (OP)
  code[13] = 1'b1; ---------> opcode = 7'b01_101_11 - Type U  (LUI)
  code[14] = 1'b1; ---------> opcode = 7'b01_110_11 - Type R  (OP-32)
  code[16] = 1'b1; ---------> opcode = 7'b10_000_11 - Type R4 (MADD)
  code[17] = 1'b1; ---------> opcode = 7'b10_001_11 - Type R4 (MSUB)
  code[18] = 1'b1; ---------> opcode = 7'b10_010_11 - Type R4 (NMSUB)
  code[19] = 1'b1; ---------> opcode = 7'b10_011_11 - Type R4 (NMADD)
  code[20] = 1'b1; ---------> opcode = 7'b10_100_11 - Type R  (OP-FP)
  code[24] = 1'b1; ---------> opcode = 7'b11_000_11 - Type SB (BRANCH)
  code[25] = 1'b1; ---------> opcode = 7'b11_001_11 - Type I  (JALR)
  code[27] = 1'b1; ---------> opcode = 7'b11_011_11 - Type UJ (JAL)
  code[28] = 1'b1; ---------> opcode = 7'b11_100_11 - Type I  (SYSTEM)
*/

module opdecoder (
    input [6:0]   opcode,
    output [31:0] code
);
    wire [3:0] group_a;
    wire [7:0] group_b;

    decoder #(2) dec2to5 (
        .data_i(opcode[6:5]),
        .data_o(group_a)
    );

    decoder #(3) dec3to8 (
        .data_i(opcode[4:2]),
        .data_o(group_b)
    );

	genvar i, j;
	generate
		for (i = 0; i < 4; i = i + 1) begin : GA
			for (j = 0; j < 8; j = j + 1) begin : GB
				assign code[8 * i + j] = group_a[i] & group_b[j];
			end
		end
	endgenerate

endmodule
