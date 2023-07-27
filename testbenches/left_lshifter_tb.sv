`timescale 1ns / 100ps
/* Testbench para o módulo do Left Logical Shift.
Shifta um valor A para esquerda B = i vezes, com i = {0, 1, ... , 64}, e compara o resultado com a saida do módulo.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros.
Ao final, mostra a quantidade total de erros obtidos */
module left_lshifter_tb ();
logic [63:0] a, b, correct;
logic [63:0] s;
integer i, errors;

// módulo testado
left_lshifter UUT (.a, .b, .s);

initial begin
    errors = 0;
    a = 1'b1; // Parâmetro, valor que será shiftado para a esquerda

    // Laços for que passa por todos os valores de i em que é necessário dar shift 
    for (i = 0; i < 64; i = i +1 ) begin
        b = i;
        correct = a << b;
    #10
    assert (correct == s) else begin 
        errors += 1;
        $display ("--Error--");
        $display ("Operand A: %h Operand B: %h", a, b);
        $display ("got value: %h", s);
        $display ("Correct value: %h", correct);
		$display ("--------");
    end
    end
    $display ("Finished, got %2d errors", errors);
    $finish;
end

endmodule