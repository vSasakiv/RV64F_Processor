`timescale  1ns / 100ps
/* Testbench para o módulo da Unidade Lógica Aritmética - ALU
Para dois números de 64 bits, A e B (parâmetros arbitrários), performa todas as operações lógicas e aritméticas,
passando por todos os valores de FUNC, tanto para sub_sra = 0 ou sub_sra = 1.
Caso algum resultado seja diferente do esperado ("xpect"), mostra os valores obtidos na saída e aumenta a contagem de erros.  
Ao final, mostra a quantidade total de erros obtidos */
module alu_tb ();
reg [63:0] a, b; // Entradas A e B da ALU unsigned
reg signed [63:0] a_signed, b_signed; // Entradas A e B signed
reg [2:0] func; // Selector de função
reg sub_sra; // Seletor de subtração ou shift aritmético
reg [63:0] correct; // reg para expressar o valor correto
reg correct_eq, correct_lu, correct_ls; // expressa os valores corretos para as comparações
wire [63:0] s; // net que contém o resultado entregue pela ALU
wire eq, lu, ls; // nets que contém os sinais de comparação
integer errors, i, j; // contadores e variáveis de suporte

// Task para conferir se os valores estão realmente corretos
// retornando feedback útil
task check_s;
  input [63:0] xpect_s;
  if (s !== xpect_s) begin 
    $display ("Error A: %h, B: %h, expected %h, got S: %h, FUNC: %3b", a, b, xpect_s, s, func);
    errors = errors + 1; 
  end
endtask
 
task check_comp;
  input xpect_eq, xpect_lu, xpect_ls;
  begin   
    if (eq !== xpect_eq) begin 
      $display ("Error A: %h, B: %h, expected EQ %b, got EQ: %b", a, b, xpect_eq, eq);
      errors = errors + 1; 
    end
    if (lu !== xpect_lu) begin 
      $display ("Error A: %h, B: %h, expected LU %b, got LU: %b", a, b, xpect_lu, lu);
      errors = errors + 1; 
    end
    if (ls !== xpect_ls) begin 
      $display ("Error A: %h, B: %h, expected LS %b, got LS: %b", a, b, xpect_ls, ls);
      errors = errors + 1; 
    end
  end 
endtask

// Unidade em teste: ALU
alu UUT (.a, .b, .func, .sub_sra, .s, .eq, .lu, .ls);

initial begin
  errors = 0;
  a = {2'b11, 62'b0}; // entradas arbitrárias de teste, já que todos os módulos já foram
                      // previamente testados com rigor, basta verificar se o seletor funciona
  b = {52'b11111111111111111111, 12'b0}; 
  a_signed = a;
  b_signed = b;

  sub_sra = 0;
  for (i = 0; i < 8; i = i + 1) begin
    // percorremos todos os valores de FUNC e testamos se os valores estão realmente corretos
    func = i;
    case (func)
      3'b000: correct = a + b;
      3'b001: correct = a << b[5:0];
      3'b100: correct = a ^ b;
      3'b101: correct = a >> b[5:0];
      3'b110: correct = a | b;
      3'b111: correct = a & b;
    endcase
    #10

    /*Operações de comparação não funcionam apropriadamente com sub_sra = 0, 
    por isso, foram desconsiderads nesse caso */
    if (func != 3'b010 && func != 3'b011) 
      check_s (correct);
  end

  // ativamos o sub_sra e testamos novamente todos os valores de FUNC
  sub_sra = 1;
  for (i = 0; i < 8; i = i + 1) begin
    func = i;
    case (func)
      3'b000: correct = a - b;
      3'b001: correct = a << b[5:0];
      3'b010: correct = a_signed < b_signed;
      3'b011: correct = a < b;
      3'b100: correct = a ^ b;
      3'b101: correct = a >>> b[5:0];
      3'b110: correct = a | b;
      3'b111: correct = a & b;
    endcase
    correct_eq = a == b;
    correct_ls = a_signed < b_signed;
    correct_lu = a < b;
    
    #10
    check_comp (correct_eq, correct_lu, correct_ls);
    check_s (correct);
  end

  $display("Finished. Got %d errors", errors);
  $finish;
  end
endmodule