`timescale 1ns / 100ps
/* 
Testbench para o comparador de desigualdade menor que, roda para todos as possíveis
combinações de A e B, sendo A e B números de 8 bits, já que executar este programa
para todas as combinações A e B de 64 bits é inviável
 */
module comparator_lt_unsigned_tb ();
reg [63:0] a, b; // A, B
wire [63:0] s; // Subtração A - B
reg correct; // Valor correto
wire eq, c_o, lu; // Valores entregues por módulos, igualdade, Carry out e Resultado
integer i, j, errors; // Contadores

task check;
    input expect_lu;
    if (lu !== expect_lu) begin 
        $display ("Error A: %32b, B: %32B, COUT: %b, xpect: %b, EQ: %b", a, b, c_o, expect_lu, eq);
        errors = errors + 1;
    end
endtask

// Unidade em teste: comparador de desigualdade menor que
comparator_lt_unsigned UUT (.c_o, .eq, .lu);
// Utilização do módulo de soma para obter a subtração
adder64b A1 (.a, .b, .s, .sub(1'b1), .c_o);
// Utilização do módulo de comparação igual para obter a igualdade.
comparator_eq E1 (.s, .eq);
initial begin
    errors = 0;

    for (i = 0; i < 256; i = i + 1) begin
      for (j = -256; j < 256; j = j + 1) begin
        a = i;
        b = j;
        correct = a < b;
        #1
        check (correct);
      end
    end
    $display ("Finished, got %2d errors", errors);
end

endmodule