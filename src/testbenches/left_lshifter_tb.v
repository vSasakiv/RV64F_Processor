`timescale 1ns / 100ps
/* Testbench para o módulo do Left Logical Shift.
Shifta um valor A para esquerda B = i vezes, com i = {0, 1, ... , 32}, e compara o resultado com a saida do módulo.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros.
Ao final, mostra a quantidade total de erros obtidos */
module left_lshifter_tb ();
reg [63:0] a, b, correct;
wire [63:0] s;
integer i, errors;

// task que verifica se a saída do módulo é igual ao valor esperado 
task check;
    input [63:0] xpect;
    if (s !== xpect) begin 
        $display ("Error A: %32b, B: %32b, got %32b", a, b, s);
        errors = errors + 1;
    end
endtask

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
    $display ("A: %64b, B: %6b", a, b);
    $display ("correct: %32b, C: %32b", correct, s);
    check (correct);
    end
    $display ("Finished, got %2d errors", errors);
end

endmodule