/* Memória de dados. 
Armazena dados da entrada "data_i" de forma síncrono e em formato little endian a partir do endereço "addr",
de acordo com o tamanho da palavra especificado pelo seletor "sel_mem_size".
Tem como saída uma palavra de 64 bits, a qual esta armazenada nesse mesmo formato em 8 posições partir de "addr" 

Valores do seletor sel_mem_size o qual tamanho eles indicam:
00 - byte
01 - halfword
10 - word
11 - doubleword
*/
module data_memory (
  input clk,
  input write,
  input [1:0] sel_mem_size, 
  input [63:0] data_i,
  input [63:0] addr,
  output [63:0] data_o
);
  reg [7:0] memory [0:255];

  assign data_o = {memory[addr + 7], memory[addr + 6], memory[addr + 5], memory[addr + 4], memory[addr + 3], memory[addr + 2], memory[addr + 1], memory[addr]};

  //Na borda de subida do clk, escreve na memória somente se write for 1 
  always @(posedge clk) begin
    if (write) begin
      case (sel_mem_size)
        2'b00: begin //byte
          memory[addr] <= data_i[7:0];
        end
        2'b01: begin //halfword
          memory[addr] <= data_i[7:0];
          memory[addr + 1] <= data_i[15:8];
        end 
        2'b10: begin //word
          memory[addr] <= data_i[7:0];
          memory[addr + 1] <= data_i[15:8];
          memory[addr + 2] <= data_i[23:16];
          memory[addr + 3] <= data_i[31:24];
        end
        2'b11: begin //doubleword
          memory[addr] <= data_i[7:0];
          memory[addr + 1] <= data_i[15:8];
          memory[addr + 2] <= data_i[23:16];
          memory[addr + 3] <= data_i[31:24];
          memory[addr + 4] <= data_i[39:32];
          memory[addr + 5] <= data_i[47:40];
          memory[addr + 6] <= data_i[55:48];
          memory[addr + 7] <= data_i[63:56];
        end
      endcase
    end
  end

endmodule