`timescale 1ns / 100ps

/* Testbench que testa o módulo do somador Carry Look-Ahead de 8 bits.
Faz todas as somas possíves com os números de 0 a 255 e verifica se a soma S e o carry out c_o são iguais aos da saída do módulo.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros 
Ao final, mostra a quantidade total de erros obtidos */
module cla_adder8b_tb ();
reg [7:0] a, b, correct_s;
reg [8:0] sum; // Variável responsável por armazenar a soma a + B 
reg c_i, correct_cout;
wire c_o;
wire [7:0] s;
integer errors, i , j;

task display_error;
    begin
        errors += 1;
        $display ("--Error--");
        $display ("Operand A: %h Operand B: %h", a, b);
        $display ("got value: %h , got cout: %b", s, c_o);
        $display ("Correct value: %h, correct cout: %b.", correct_s, correct_cout);
		$display ("--------");
    end
endtask

// módulo testado
cla_adder8b UUT (.a, .b, .c_i, .s, .c_o);

initial begin 
    errors = 0;    
    // Laços for que passam por todas as somas possíveis entre os números de 0 a 255 
    for (i = 0; i < 256; i = i + 1)
        for (j = 0; j < 256; j = j + 1) begin
            c_i = $random & 1'b1;
            a = i;
            b = j;
            sum = a + b + c_i;
            correct_s = sum[7:0]; 
            correct_cout = sum[8]; // posição do carry out
            #10;
            assert (correct_s == s) else display_error();
            assert (correct_cout == c_o) else display_error();
        end
    $display ("Finished, got %2d errors", errors);
    $finish;
end


endmodule
