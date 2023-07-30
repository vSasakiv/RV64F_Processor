`timescale  1ns / 100ps

/* Testbench para o somador/subtrator de floating point 
Define o modo de arredondamento, os operandos e a operação e revela o resultado obtido */
module add_sub_fp_tb ();

import "DPI-C" function longint add_float(longint a, longint b);

parameter Size = 64; //Quad, double ou single precision (128, 64 ou 32, respectivamente)
logic [2:0] rounding_mode;
logic sub, start;
logic [Size - 1:0] operand_a;
logic [Size - 1:0] operand_b;
logic clk;
logic [Size - 1:0] result_32;
logic [Size - 1:0] result_64;
logic overflow_32, inexact_32, underflow_32, invalid_32, done_32;
logic overflow_64, inexact_64, underflow_64, invalid_64, done_64;
integer errors, precision, i;
longint correct_result;

initial
    clk = 1; // Clock inicial estabelecido como 1;

always 
    #1 clk = ~clk;

	task display_error;
	begin
    errors += 1;
		$display("--Error--");
		$display("Operand A: %h Operand B: %h Sub: %b", operand_a, operand_b, sub);
		if (precision == 32)
			$display("Result: %h NV: %b OF: %b UF: %b NX: %b", result_32, invalid_32, overflow_32, underflow_32, inexact_32);
		else 
			$display("Result: %h NV: %b OF: %b UF: %b NX: %b", result_64, invalid_64, overflow_64, underflow_64, inexact_64);

    $display ("Correct value: %h.", correct_result);
		$display("--------");
	end
  endtask

//Módulo testado
add_sub_fp #(.Size(32)) UUT_32 (
  .clk(clk),
  .rounding_mode(rounding_mode),
  .sub(sub),
  .start(start),
  .operand_a(operand_a),
  .operand_b(operand_b),
  .result(result_32),
  .overflow(overflow_32),
  .inexact(inexact_32),
  .underflow(underflow_32),
  .invalid(invalid_32),
  .done(done_32)
);

add_sub_fp #(.Size(64)) UUT_64 (
  .clk(clk),
  .rounding_mode(rounding_mode),
  .sub(sub),
  .start(start),
  .operand_a(operand_a),
  .operand_b(operand_b),
  .result(result_64),
  .overflow(overflow_64),
  .inexact(inexact_64),
  .underflow(underflow_64),
  .invalid(invalid_64),
  .done(done_64)
);

//Descomente as linhas da precisão que deseja testar. Não esqueça de alterar o parâmetro Size
initial begin
	
	errors = 0;
    #2
    $dumpfile("add_sub_fp.vcd");
    $dumpvars(100, add_sub_fp_tb);
    
    //Inicia FSM
    start = 1'b1;

    rounding_mode = 3'b000;
    sub = 1'b0;

    for (i = 0; i < 10000; i++) begin
        operand_a = {$urandom, $urandom};
        operand_b = {$urandom, $urandom};
        correct_result = add_float(operand_a, operand_b);
        while (done_32 !== 1'b1) #1;
        assert (correct_result === result_64) else display_error();
        #1;
    end
    $display("Got %d errors", errors);
    $stop;
end

endmodule