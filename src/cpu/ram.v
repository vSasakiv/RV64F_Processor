/* Módulo da memória RAM utilizada para simulação do projeto, não sendo um
módulo convencional, mas apenas uma forma de realizar os testes. */
module ram (
    input clk_mem,
    input [31:0] data_i,
    input [1:0] mem_size,
    input [31:0] addr,
    output [31:0] data_o
);

reg [7:0] memory [0 : 5]; // precisaria ser 32'hffffffff, mas não é conveniente ter uma memória de tamanho máximo na simulação. 

  /* Escolha do teste para ser executado 
    Formato da setença: $readmemh({"tests/","teste","/RAM.hex"}, memory);
    No lugar de "teste", substituir por uma das opções abaixo: 

    testeVariavel -> Executa o teste de um arquivo em C testando funcionalidade
  básica de declaração e armazenamento de variáveis
    
    testeVetor -> Executa o teste de um arquivo em C testando funcionalidade
  básica de declaração, armazenamento e modificação de vetores
    
    testeOperacoes -> Executa o teste de um arquivo em C testando funcionalidade
  básica de operacoes aritméticas e lógicas
    
    testeFuncoes -> Executa o teste de um arquivo em C testando funcionalidade
  básica de declaração e utilização de funções
    
    testeRecursao -> Executa o teste de um arquivo em C testando funcionalidade
  básica de recursão
    
    testeHeapsort -> Executa o teste de um arquivo em C testando funcionalidade
  de um heapsort
  
    testeInstrucoes -> Executa o teste de um arquivo que contém todas as instruções da ISA do 
  RISC-V 32I.
  */
/* APENAS PARA A REALIZAÇÃO DE TESTES*/
/*!!!!!!*/
initial begin
  // realiza carregamento de um arquivo .hex para a memória
  $readmemh({"testes/","testeRecursao","/RAM.hex"}, memory);
end
/*!!!!!!*/
always @(posedge clk_mem) begin
    if (mem_size == 2'd0) begin
        memory[addr] <= data_i[7:0];
    end
    if (mem_size == 2'd1) begin
        memory[addr] <= data_i[7:0];
        memory[addr+1] <= data_i[15:8];
    end
    if (mem_size == 2'd2) begin
        memory[addr] <= data_i[7:0];
        memory[addr+1] <= data_i[15:8];
        memory[addr+2] <= data_i[23:16];
        memory[addr+3] <= data_i[31:24];
    end
end
/* APENAS PARA A REALIZAÇÃO DE TESTES*/
/*!!!!!!*/
/*
always @(*) begin
  // cada vez que qualquer sinal muda, escreve/sobrescreve um arquivo .hex contendo o conteúdo da memória RAM
  $writememh("RAMOUT.hex", memory);
end 
*/
/*!!!!!!*/
assign data_o = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]};

endmodule
