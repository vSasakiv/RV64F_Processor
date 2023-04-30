`timescale 1ns / 100ps
/* 
Testbench para o comparador, que devolve igualdades
signed e unsigned, que roda para todos as possíveis
combinações de A e B, sendo A e B números signed em complemento de 2 
de 8 bits, já que executar este programa
para todas as combinações A e B de 64 bits é inviável
*/
module comparator_tb ();
reg [63:0] a, b; // A, B
reg signed [63:0] a_signed, b_signed; // A e B signed
wire [63:0] s; // Subtração A - B
reg correct_lu, correct_ls, correct_eq; // Valor correto
wire eq, c_o, ls, lu; // Valores entregues por módulos, igualdade, Carry out e Resultado
integer i, j, errors; // Contadores

task check_u;
  input expect_lu;
  if (expect_lu !== lu) begin
    $display("unsigned: A: %64b, B: %64b, expect: %b", a, b, lu);
    errors = errors + 1;
  end
endtask
task check_s; 
  input expect_ls;
  if (expect_ls !== ls) begin
    $display("signed: A: %64b, B: %64b, expect: %b", a, b, ls);
    errors = errors + 1;
  end
endtask
task check_eq;
  input expect_eq;
  if (expect_eq !== eq) begin
    $display("equality: A: %64b, B: %64b, expect: %b", a, b, eq);
    errors = errors + 1;
  end
endtask

// Unidade em test: comparador completo
comparator UUT (.a_sign(a_signed[63]), .b_sign(b_signed[63]), .s, .c_o, .eq, .ls, .lu);
// Utilização do módulo de soma para obter a subtração
adder64b A1 (.a, .b, .s, .sub(1'b1), .c_o);

initial begin
    errors = 0;
    for (i = 0; i < 1000; i = i + 1) begin
        a = {$urandom, $urandom};
        b = {$urandom, $urandom};
        a_signed = {$urandom, $urandom};
        b_signed = {$urandom, $urandom};
        correct_lu = a < b;
        correct_ls = a_signed < b_signed;
        correct_eq = a == b;
        #1
        check_u (correct_lu);
        check_s (correct_ls);
        check_eq(correct_eq);
    end
    $display ("Finished, got %2d errors", errors);
    $finish;
end

endmodule