`timescale  1ns / 100ps

//Testbench para o módulo do somador de n bits "adder".
module adder_tb ();
parameter InputSize = 64;
reg [InputSize - 1:0] a, b, correct_s;
reg [InputSize:0] sum; // Variável responsável por armazenar a soma A + B ou A + (-B)
reg sub, correct_cout;
wire [InputSize - 1:0] s;
wire c_o;
integer errors, i; 

// task que verifica se a saída do módulo é igual ao valor esperado*/
task check; 
    input [InputSize - 1:0] xpect_s;
    input xpect_cout; 
    begin 
        if (s !== xpect_s) begin 
            $display ("Error A: %b, B: %b, expected %b, got S: %b", a, b, xpect_s, s);
            errors = errors + 1;
        end
        if (c_o !== xpect_cout) begin
            $display ("Error A: %b, B: %b, expected %b, got COUT: %b", a, b, xpect_cout, c_o);
            errors = errors + 1;
        end
    end
endtask

// módulo testado
  adder #(InputSize) UUT (.a, .b, .sub, .s, .c_o);

initial begin
    errors = 0;
    sub = 1'b1; //Parâmetro para teste: 0 para fazer A + B, 1 para A + (-B)
    // Laços for que passam por todas as somas possíveis entre os números de 0 a 255

    for (i = 0; i < 1000; i = i + 1) begin
      a = {$urandom, $urandom};
      b = {$urandom, $urandom};
      sub = $urandom & 1'b1;
      sum = (sub == 1'b0) ? a + b : a + (b ^ {(InputSize){1'b1}}) + 1;
      correct_s = sum[InputSize - 1:0];
      correct_cout = sum[InputSize];
      #10;
      check (correct_s, correct_cout);
    end

    $display ("Finished, got %2d errors", errors);
    $finish;
end

endmodule