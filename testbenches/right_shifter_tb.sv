`timescale 1ns / 100ps
/* Testbench para o módulo de Right Logical/Arithmetic Shift
Shifta um valor A para direita B = i vezes, com i = {0, 1, ... , 64}, e compara o resultado com a saida do módulo.
Se algum valor for diferente do esperado, mostra os valores na saída e aumenta a contagem do erros.
Ao final, mostra a quantidade total de erros obtidos */
module right_shifter_tb ();
logic signed [63:0] a, b, correct;
logic signed [63:0] s;
logic sra; 
integer errors, i;

// task que verifica se a saída do módulo é igual ao valor esperado 
task check;
    input [63:0] xpect;
    if (s !== xpect) begin
        $display ("Error A: %64b, B: %6b, got %64b", a, b, s);
        errors = errors + 1;
    end
endtask

// módulo testado
right_shifter UUT (.a, .b, .sra, .s);

initial begin
  errors = 0;

  // Laços for que passa por todos os valores de i em que é necessário dar shift 
  for (i = 0; i < 64; i = i +1) begin
			sra = 1'b1;
			a = {$urandom, $urandom}; // valor que será shiftado para a direita
      b = i; //Quantidade de shifts
      if (sra == 0) correct = a >> i;
      else correct = a >>> i;
      #10 
			assert (correct == s) else begin
        errors += 1;
        $display ("--Error--");
        $display ("Operand A: %b Operand B: %2d", a, b);
        $display ("got result: %b ", s);
        $display ("Correct value: %b", correct);
				$display ("--------");
    end
  end
  $display ("Finished, got %2d errors", errors);
  $finish;
end

endmodule