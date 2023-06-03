/* Memória de instruções
Tem finalidade de armazenar, no formato little endian, as instruções que serão executadas pelo circuito.
Direciona na saída a concatenação do falor presente no endereço "addr" e os 3 seguintes. 
*/
module insn_memory (
  input [63:0] addr,
  output [31:0] insn
);
  reg [7:0] memory [0:255];
    
  assign insn = {memory[addr], memory[addr + 1], memory[addr + 2], memory[addr + 3]};

  initial begin
    $readmemh({"testes/", "testeInstrucoes/","RAM.hex"}, memory);
  end

endmodule