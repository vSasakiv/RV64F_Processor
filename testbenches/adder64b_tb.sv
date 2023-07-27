`timescale  1ns / 100ps

/* Testbench para o módulo do somador de 64 bits Adder64B.
Performa somas aleatórias com números de 64 bits e compara os resultados da soma S e do c_o (carry out) com os obtidos no módulo.
Caso algum resultado seja diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem de erros.  
Ao final, mostra a quantidade total de erros obtidos */
module adder64b_tb ();
logic [63:0] a, b, correct_s;
logic [64:0] sum; // Variável responsável por armazenar a soma A + B ou A + (-B)
logic sub, correct_cout;
logic [63:0] s;
logic c_o;
integer errors, i; 

task display_error;
    begin
        errors += 1;
        $display ("--Error--");
        $display ("Operand A: %h Operand B: %h Sub: %b", a, b, sub);
        $display ("got value: %h , got cout: %b", s, c_o);
        $display ("Correct value: %h, correct cout: %b.", correct_s, correct_cout);
		$display ("--------");
    end
endtask

// módulo testado
adder64b UUT (.a, .b, .sub, .s, .c_o);

initial begin
    errors = 0;
    sub = 1'b1; //Parâmetro para teste: 0 para fazer A + B, 1 para A + (-B)

    for (i = 0; i < 1000; i = i + 1) begin
      a = {$urandom, $urandom};
      b = {$urandom, $urandom};
      sub = $urandom & 1'b1;
      sum = (sub == 1'b0) ? a + b: a + (b ^ {(64){1'b1}}) + 1;
      correct_s = sum[63:0];
      correct_cout = sum[64];
      #10;
      assert (correct_s == s) else display_error();
      assert (correct_cout == c_o) else display_error();
    end

    $display ("Finished, got %2d errors", errors);
    $finish;
end



endmodule