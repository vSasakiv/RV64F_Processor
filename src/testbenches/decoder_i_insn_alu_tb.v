`timescale 1ns / 100ps
/* Testbench para teste do Decodificador de instruções do tipo I alu, que confere
todas as saídas do módulo com as saídas corretas, e ao final retorna o número
de erros, se houver. */
module decoder_i_insn_alu_tb ();

reg [31:0] insn; // reg que contém a instrução

// reg que contém o valor correto da saída do módulo
reg sub_sra_c;

// net contendo a saída do módulo em teste
wire sub_sra;

integer errors; // contador

/* Task verifica se o valor esperado é igual ao valor devolvido pelo módulo */
task Check;
  input sub_sra_x;
  begin
  if (sub_sra_x !== sub_sra) begin
    $display("Error on sub_sra: %b, Expected: %b", sub_sra, sub_sra_x);
    errors = errors + 1;
  end
  end
endtask

// Unidade em teste: Decoder  de instruções do tipo I para alu
decoder_i_insn_alu UUT (
  .insn(insn),
  .sub_sra(sub_sra)
);


initial begin
  errors = 0;
  // Instrução arbitrária: soma de um registrador com um imediato
  insn = 32'h00A10093;
  sub_sra_c = 0;

  #10;
  Check(sub_sra_c);

  // Instrução arbitrária: shift right aritmético de um registrador com um imediato
  insn = 32'h4027DA13;
  sub_sra_c = 1;

  #10;
  Check(sub_sra_c);

  $display("Finished, got %d errors", errors);
  $finish;
end
endmodule