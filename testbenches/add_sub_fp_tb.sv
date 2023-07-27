`timescale  1ns / 100ps

/* Testbench para o somador/subtrator de floating point 
Define o modo de arredondamento, os operandos e a operação e revela o resultado obtido */
module add_sub_fp_tb ();
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
integer errors, precision;
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

/////////////////////////////////////////////// Single precision (Size = 32) /////////////////////////////////////////////////////////
	precision = 32;

	rounding_mode = 3'b000;
  sub = 1'b0;
  operand_a = 32'b0_01111101_00000000000000000000000;
  operand_b = 32'b0_10000101_10010000000000000000000;
  //Result        0_10000101_10010001000000000000000 = 0x42C88000;
	correct_result = 32'h42C88000;

  #1
  while (done_32 !== 1'b1) #1;
	assert (correct_result === result_32) else display_error();

  sub = 1'b1;
  operand_a = 32'b0_10000001_10010001000000000000000;
  operand_b = 32'b0_10000000_11100000000000000000000;
	//Result        0_10000000_01000010000000000000000 = 0x40210000;
	correct_result = 32'h40210000;
  #2
  while (done_32 !== 1'b1) #1;
	assert (correct_result === result_32) else display_error();

  sub = 1'b0;
  rounding_mode = 3'b010;
  operand_a = 32'b1_10000000_11000000000000000011111;
  operand_b = 32'b1_10000010_11100000000000000001001;
  //Result        1_10000011_00101000000000000001000 = 0xC1940009; 
	correct_result = 32'hC1940009;
  #2
  while (done_32 !== 1'b1) #1;
	assert (correct_result === result_32) else display_error();

///////////////////////////////////////////////Double precision  (Size = 64) /////////////////////////////////////////////////////////
  precision = 64;

	sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b1_11111111110_0001111110010100000000011110000000000000101110000000;
  operand_b = 64'b1_11111111111_0000000000000000000000000000000000000000000000000000;
  //Result       invalid;
  #2
  while (done_64 !== 1'b1) #1;
	assert (invalid_64 === 1'b1) else $display("Flag error! Expected NV: 1, got NV: %b", invalid_64);

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_01111111111_1000000000000000000000000000000000000000000000000000;
  operand_b = 64'b1_01111111111_1000000000000000000000000000000000000000000000000000;
  //Result        0_10000000000_1000000000000000000000000000000000000000000000000000 = 0x4008000000000000;
	correct_result = 64'h4008000000000000;
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();

  sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b0;
  operand_b = 64'b0;
  //Result        0 = 0x0;
	correct_result = 64'h0;
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_00000000000_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_01111111110_0000000000000000000000000000000000000000000000000000;
  //Result        1_01111111110_0000000000000000000000000000000000000000000000000000 = 0xBFE0000000000000;
	correct_result = 64'hBFE0000000000000;
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();

  sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b0_11111111110_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_11111111110_0000000000000000000000000000000000000000000000000000;
  //Result        0_11111111111_0000000000000000000000000000000000000000000000000000 = 0x7FF0000000000000;
	correct_result = 64'h7FF0000000000000;
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();

  sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b0_00000000000_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_00000000001_0000000100000000000000000000000000000000000000000000;
  //Result        0_00000000010_0000000000000000000000000000000000000000000000000000 = 0x0020000000000000;
	correct_result = 64'h0020000000000000;
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_00000000000_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_00000000001_0000000100000000000000000000000000000000000000000000;
  //Result        1_00000000000_0000000111111111111111111111111111111111111111111111 = 0x80001FFFFFFFFFFF;
	correct_result = 64'h80001FFFFFFFFFFF; 
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_10000101010_0011111111100000010110000000000010000010001001101000;
  operand_b = 64'b1_10000101010_0000000000000000000000000000000000000000000000000000;
  //Result        0_10000101011_0001111111110000001011000000000001000001000100110100 = 0x42B1FF02C0041134;
	correct_result = 64'h42B1FF02C0041134; 
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();
 
  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b1_11111010111_0001111110010100000000011110000000000000101110000000;
  operand_b = 64'b0_10000101010_0000000000000000000000000000000000000000000000000000;
  //Result        1_11111010111_0001111110010100000000011110000000000000101110000000 = 0xFD71F9401E000B80;
	correct_result = 64'hFD71F9401E000B80; 
  #2
  while (done_64 !== 1'b1) #1;
	assert (correct_result === result_64) else display_error();
 
	$display("Finished, got %2d errors", errors);
	$finish;
end

endmodule