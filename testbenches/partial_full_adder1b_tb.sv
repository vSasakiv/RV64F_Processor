`timescale 1ns / 100ps
/* Testbench para o módulo do somador parcial de 1 bit.
Faz todas as combinações de somas possíves com números de 1 bit e verifica se a soma S, o propagate P, e o generate G, são iguais aos da saída do módulo.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros 
Ao final, mostra a quantidade total de erros obtidos */
module partial_full_adder1b_tb ();
logic a, b, c_i, correct_s, correct_p, correct_g;
logic s, p, g;
integer errors, i , j;

task display_error;
    begin
        errors += 1;
        $display ("--Error--");
        $display ("Operand A: %b Operand B: %b", a, b);
        $display ("Got values result: %b, propagate: %b, generate: %b", s, p, g);
        $display ("Correct result: %b, propagate: %b, generate: %b", correct_s, correct_p, correct_g);
		    $display ("--------");
    end
endtask

// módulo testado
partial_full_adder1b UUT (.a, .b, .c_i, .s, .p, .g);

	initial begin
		errors = 0;
		c_i = 1; //Parâmetro para teste: 0 para fazer A + B com carry in igual a 0, 1 para fazer o mesmo com carry igual a 1

		/* Laços for que passam por todas combinações possíveis de soma com números de 1bit */
		for (i = 0; i < 2; i = i + 1)
			for (j = 0; j < 2; j = j + 1) begin
				c_i = $urandom & 1'b1;
				a = i;
				b = j;
				correct_s = a + b + c_i; //Soma
				correct_p = a | b;       //Propagate
				correct_g = a & b;       //Generate
				#10
				assert (correct_s == s) else display_error;
				assert (correct_p == p) else display_error;
				assert (correct_g == g) else display_error;
			end
		$display ("Finished, got %2d errors", errors);
		$finish;
	end 

endmodule 