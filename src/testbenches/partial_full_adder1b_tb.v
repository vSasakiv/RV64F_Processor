`timescale 1ns / 100ps
/* Testbench para o módulo do somador parcial de 1 bit.
Faz todas as combinações de somas possíves com números de 1 bit e verifica se a soma S, o propagate P, e o generate G, são iguais aos da saída do módulo.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros 
Ao final, mostra a quantidade total de erros obtidos */
module partial_full_adder1b_tb ();
reg a, b, c_i, correct_s, correct_p, correct_g;
wire s, p, g;
integer errors, i , j;

/* task que verifica se a saída do módulo é igual ao valor esperado */
task check; 
    input expected_s, expected_p, expected_g;
    begin 
        if (s != expected_s) begin 
            $display ("Error A: %b, B: %b, expected %b, got S: %b", a, a, expected_s, s);
            errors = errors + 1;
        end
        if (p != expected_p) begin 
            $display ("Error A: %b, B: %b, expected %b, got P: %b", a, b, expected_p, p);
            errors = errors + 1;
        end
        if (g != expected_g) begin 
            $display ("Error A: %b, B: %b, expected %b, got G: %b", a, b, expected_g, g);
            errors = errors + 1;
        end
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
            a = i;
            b = j;
            correct_s = a + b + c_i; //Soma
            correct_p = a | b; //Propagate
            correct_g = a & b; //Generate
            #10
            $display ("A: %b, B: %b, c_i: %b correct_s: %b, correct_p: %b, correct_g: %b ", a, b, c_i, correct_s, correct_p, correct_g);
            check (correct_s, correct_p, correct_g);
        end
    $display ("Finished, got %2d errors", errors);
end 

endmodule 