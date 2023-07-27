`timescale 1ns / 100ps
/* 
Testbench para o comparador, que devolve igualdades
signed e unsigned, que roda para todos as possíveis
combinações de A e B, sendo A e B números signed em complemento de 2 
de 8 bits, já que executar este programa
para todas as combinações A e B de 64 bits é inviável
*/
module comparator_tb ();
logic [63:0] a, b; // A, B
logic signed [63:0] a_signed, b_signed; // A e B signed
logic correct_lu, correct_ls, correct_eq; // Valor correto
logic eq, ls, lu; // Valores entregues por módulos, igualdade, Carry out e Resultado
integer i, j, errors; // Contadores

	task display_error;
		begin 
			errors += 1;
      $display ("--Error--");
      $display ("Operand A: %h Operand B: %h", a, b);
      $display ("got values eq: %b, lu: %b, ls: %b", eq, lu, ls);
      $display ("Correct values eq: %b, lu: %b, ls: %b ", correct_eq, correct_lu, correct_ls);
		  $display ("--------");
		end
	endtask

// Unidade em test: comparador completo
comparator UUT (.a(a), .b(b), .eq(eq), .ls(ls), .lu(lu));

initial begin
    errors = 0;
    for (i = 0; i < 1000; i = i + 1) begin
        a = $urandom;
        b = $urandom;
        a_signed = a;
        b_signed = b;
        correct_lu = a < b;
        correct_ls = a_signed < b_signed;
        correct_eq = a == b;
        #1
				assert (correct_eq === eq) else display_error;
				assert (correct_ls === ls) else display_error;
				assert (correct_lu === lu) else display_error;
    end
    $display ("Finished, got %2d errors", errors);
    $finish;
end
endmodule
