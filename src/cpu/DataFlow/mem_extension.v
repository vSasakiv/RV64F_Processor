/* Módulo utilizado para realizar a extensão de um valor proveniente da memória de dados, para ser corretamente
armazenado em um registrador. 

Valores de sel_mem_extension e a extensão que selecionam:
000 - Load byte
001 - Load byte unsigned
010 - load halfword
011 - load halfword unsigned 
100 - load word
101 - load word unsigned
110 - Load doubleword 
*/
module mem_extension (
  input [2:0] sel_mem_extension,  // entrada para definir qual deve ser a extensão a ser realizada
  input [63:0] mem_value,         // entrada do valor de memória
  output reg [63:0] mem_extended  // saída do valor de memória estendido
);
  wire [63:0] load_byte, load_byte_unsigned, load_halfword, load_halfword_unsigned, load_word, load_word_unsigned, load_doubleword;

  assign load_byte = {{56{mem_value[7]}}, mem_value[7:0]};       // Load byte (signed extension)
  assign load_byte_unsigned = {56'b0, mem_value[7:0]};           // Load byte
  assign load_halfword = {{48{mem_value[15]}}, mem_value[15:0]}; // Load halfword (signed extension)
  assign load_halfword_unsigned = {48'b0, mem_value[15:0]};      // Load halfword 
  assign load_word = {{32{mem_value[31]}}, mem_value[31:0]};     // Load word (signed extension);
  assign load_word_unsigned = {32'b0, mem_value[31:0]};          // load word
  assign load_doubleword = mem_value;                            // load doubleword

  //Mux que seleciona, com base no sel_mem_extension, qual resultado será direcionado pra saída do módulo
  always @(*) begin
    case (sel_mem_extension)
      3'b000: mem_extended = load_byte;
      3'b001: mem_extended = load_byte_unsigned;
      3'b010: mem_extended = load_halfword;
      3'b011: mem_extended = load_halfword_unsigned;
      3'b100: mem_extended = load_word;
      3'b101: mem_extended = load_word_unsigned;
      3'b110: mem_extended = load_doubleword;
      default: mem_extended = 64'b0;
    endcase    
    end
endmodule