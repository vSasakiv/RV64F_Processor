`timescale  1ns / 100ps

/* Testbench para o módulo do somador de 64 bits Adder64B.
Performa somas aleatórias com números de 64 bits e compara os resultados da soma S e do c_o (carry out) com os obtidos no módulo.
Caso algum resultado seja diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem de erros.  
Ao final, mostra a quantidade total de erros obtidos */
module adder64b_tb ();
reg [63:0] a, b, correct_s;
reg [64:0] sum; // Variável responsável por armazenar a soma A + B ou A + (-B)
reg sub, correct_cout;
wire [63:0] s;
wire c_o;
integer errors, i; 

// task que verifica se a saída do módulo é igual ao valor esperado*/
task check; 
    input [63:0] xpect_s;
    input xpect_cout; 
    begin 
        if (s != xpect_s) begin 
            $display ("Error A: %64b, B: %64b, expected %64b, got S: %64b", a, b, xpect_s, s);
            errors = errors + 1;
        end
        if (c_o != xpect_cout) begin
            $display ("Error A: %64b, B: %64b, expected %b, got COUT: %b", a, b, xpect_cout, c_o);
            errors = errors + 1;
        end
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
      sum = (sub == 1'b0) ? a + b : a + (b ^ {(64){1'b1}}) + 1;
      correct_s = sum[63:0];
      correct_cout = sum[64];
      #10;
      check (correct_s, correct_cout);
    end

    $display ("Finished, got %2d errors", errors);
    $finish;
end

endmodule