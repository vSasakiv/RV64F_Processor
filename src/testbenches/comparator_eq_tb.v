`timescale 1ns / 100ps
/* 
Testbench para o comparador de igualdade, roda para todos as possíveis
saídas de uma subtração entre A e B, porém apenas todas de 16 bits,
já que todas as combinações de 64 bits não é viável
 */
module comparator_eq_tb ();
reg [63:0] s; // Subtração A - B
reg correct; // Valor correto
wire eq; // Valor entregue pelo módulo
integer i, errors; // Contadores

task check;
    input xpect_eq;
    if (eq !== xpect_eq) begin 
        $display ("Error S: %64b, xpect: %b", s, eq);
        errors = errors + 1;
    end
endtask

// Unidade em teste: comparador de igualdade
comparator_eq UUT (.s, .eq);

initial begin
    errors = 0;
    for (i = 0; i < 65536; i = i + 1) begin
      s = i;
      correct = 0;
      if (s == 64'b0) begin
        correct = 1;
      end
      check(correct);
    end
    
    $display ("Finished, got %2d errors", errors);
end

endmodule