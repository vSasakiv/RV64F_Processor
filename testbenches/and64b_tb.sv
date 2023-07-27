`timescale 1ns / 100ps
/* Testbench para o módulo AND de 32bits
Para todos dois números entre 0 e 255, faz um bitwise AND deles e compara o resultado com a saída And do módulo.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros.
Ao final, mostra a quantidade total de erros obtidos */
module and64b_tb ();

logic [63:0] a, b, correct_s, s;
int errors, i, j;

// módulo testado
and64b UUT (.a, .b, .s);

initial begin
    errors = 0;

    // geramos números aleatórios para serem testados
    for (i = 0; i < 1000; i = i + 1) begin
        a = {$urandom, $urandom};
        b = {$urandom, $urandom};
        correct_s = a & b;
        #10
        assert(s === correct_s) else begin 
        errors += 1; 
        $display ("Error A: %64b, B: %64b, expected %64b, got And: %64b", a, b, correct_s, s);
        end
    end

    $display("Finished. Got %d errors", errors);
    $finish;
end

endmodule
