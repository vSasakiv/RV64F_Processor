`timescale 1ns / 100ps
/* Testbench para o módulo XOR de 32bits
Para todos dois números entre 0 e 255, faz um bitwise XOR deles e compara o resultado com a saída X do módulo.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros.
Ao final, mostra a quantidade total de erros obtidos */
module xor64b_tb ();
reg [63:0] a, b, correct_s;
wire [63:0] s;
integer errors, i, j;

// task que verifica se a saída do módulo é igual ao valor esperado
task check;
    input [63:0] xpect_s;
    if (s != xpect_s) begin 
        $display ("Error A: %64b, B: %64b, expected %64b, got X: %64b", a, b, xpect_s, s);
        errors = errors + 1;
    end
endtask

// módulo testado
xor64b UUT (.a, .b, .s);


initial begin
    errors = 0;
    
    // Laços for que passam por todas as somas possíveis entre os números de 0 a 255
    for (i = 0; i < 256; i = i + 1)
        for (j = 0; j < 256; j = j + 1) begin
            a = i;
            b = j;
            correct_s = a ^ b;
            #10
            check (correct_s);
        end
    $display ("Finished, got %2d errors", errors);
    $finish;
end

endmodule