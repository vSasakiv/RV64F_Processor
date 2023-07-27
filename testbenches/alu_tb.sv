`timescale  1ns / 100ps
/* Testbench para o módulo da Unidade Lógica Aritmética - ALU
Para dois números de 64 bits, A e B (parâmetros arbitrários), performa todas as operações lógicas e aritméticas,
passando por todos os valores de FUNC, tanto para sub_sra = 0 ou sub_sra = 1.
Caso algum resultado seja diferente do esperado, mostra os valores obtidos na saída e aumenta a contagem de erros.  
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

	task display_error;
		begin 
			errors += 1;
      $display ("--Error--");
      $display ("Operand A: %h Operand B: %h Sub: %b", a, b, sub_sra);
      $display ("got value: %h", s);
      $display ("Correct value: %h", correct);
		  $display ("--------");
		end
	endtask

	task display_error_comparator;
		begin 
			errors += 1;
      $display ("--Error--");
      $display ("Operand A: %h Operand B: %h Sub: %b", a, b, sub_sra);
      $display ("got values eq: %b, lu: %b, ls: %b", eq, lu, ls);
      $display ("Correct values eq: %b, lu: %b, ls: %b ", correct_eq, correct_lu, correct_ls);
		  $display ("--------");
		end
	endtask

// Unidade em teste: ALU
alu UUT (.a, .b, .func, .sub_sra, .s, .eq, .lu, .ls);

initial begin
  errors = 0;
  a = $random; // entradas arbitrárias de teste, já que todos os módulos já foram
                      // previamente testados com rigor, basta verificar se o seletor funciona
  b = $random; 
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
      assert (correct == s) else display_error();
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
    assert (correct_eq == eq) else display_error_comparator();
    assert (correct_lu == lu) else display_error_comparator();
    assert (correct_ls == ls) else display_error_comparator();
    assert (correct == s) else display_error();
  end

  $display("Finished. Got %d errors", errors);
  $finish;
  end
endmodule
