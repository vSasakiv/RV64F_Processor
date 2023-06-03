`timescale 1ns / 100ps
/* 
Testbench para o comparador de desigualdade menor que, roda para todos as possíveis
combinações de A e B, sendo A e B números signed em complemento de 2 
de 8 bits, já que executar este programa
para todas as combinações A e B de 32 bits é inviável
 */
module comparator_lt_signed_tb ();
reg signed [63:0] a, b; // A, B
wire [63:0] s; // subtração A - B
reg correct; // Valor correto
wire eq, c_o, ls; // Valores entregues por módulos, igualdade, Carry out e Resultado
integer i, j, errors; // Contadores

task check;
    input xpect_ls;
    if (ls !== xpect_ls) begin 
        $display ("Error A: %64b, B: %64b, COUT: %b, xpect: %b, EQ: %b", a, b, c_o, xpect_ls, eq);
        errors = errors + 1;
    end
endtask

// Unidade em teste: comparador de igualdade
comparator_lt_signed UUT (.a_sign(a[63]), .b_sign(b[63]), .s_sign(s[63]), .eq, .ls);
// Utilização do módulo de soma para obter a subtração
adder64b a1 (.a, .b, .s, .sub(1'b1), .c_o);
// utilização do módulo de comparação igual para obter a igualdade.
comparator_eq e1 (.s, .eq);
initial begin
    errors = 0;
    for (i = -128; i < 128; i = i + 1) begin
      for (j = -128; j < 128; j = j + 1) begin
        a = i;
        b = j;
        correct = a < b;
        #1
        check (correct);
      end
    end
    $display ("Finished, got %2d errors", errors);
    $finish;
end

endmodule