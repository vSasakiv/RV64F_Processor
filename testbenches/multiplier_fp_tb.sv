`timescale  1ns / 100ps

module multiplier_fp_tb ();
parameter Size = 64;
logic [2:0] rounding_mode;
logic start, clk;
logic [Size - 1:0] operand_a;
logic [Size - 1:0] operand_b;
logic [Size - 1:0] result_32;
logic [Size - 1:0] result_64;
logic invalid_32, inexact_32, underflow_32, overflow_32, done_32;
logic invalid_64, inexact_64, underflow_64, overflow_64, done_64;
longint correct_result;
integer precision, errors; 

task display_error;
	begin
    errors += 1;
		$display("--Error--");
		$display("Operand A: %h Operand B: %h", operand_a, operand_b);
		if (precision == 32)
			$display("Result: %h NV: %b OF: %b UF: %b NX: %b", result_32, invalid_32, overflow_32, underflow_32, inexact_32);
		else 
			$display("Result: %h NV: %b OF: %b UF: %b NX: %b", result_64, invalid_64, overflow_64, underflow_64, inexact_64);

    $display ("Correct value: %h.", correct_result);
		$display("--------");
	end
  endtask

multiplier_fp #(.Size(32)) UUT_32 (
  .rounding_mode(rounding_mode),
  .start(start), 
  .clk(clk),
  .operand_a(operand_a),
  .operand_b(operand_b),
  .result(result_32),
  .invalid(invalid_32), 
  .inexact(inexact_32),
  .underflow(underflow_32),
  .overflow(overflow_32),
  .done(done_32)
);

multiplier_fp #(.Size(64)) UUT_64 (
  .rounding_mode(rounding_mode),
  .start(start), 
  .clk(clk),
  .operand_a(operand_a),
  .operand_b(operand_b),
  .result(result_64),
  .invalid(invalid_64), 
  .inexact(inexact_64),
  .underflow(underflow_64),
  .overflow(overflow_64),
  .done(done_64)
);

initial
    clk = 1; // Clock inicial estabelecido como 1;

always 
    #1 clk = ~clk;

initial begin
  #2
  $dumpfile("multiplier_fp.vcd");
  $dumpvars(1000, multiplier_fp_tb);
  errors = 0;

  //Inicia FSM
  start = 1'b1;

/////////////////////////////////////////////// Single precision (Size = 32) /////////////////////////////////////////////////////////
  precision = 32;

  rounding_mode = 3'b000;
  operand_a = 32'b1_10111111_00000000000000000000000;
  operand_b = 32'b0_11111110_00000000000000000000000;
  //Result        0_11111111_00000000000000000000000 = 0xFF800000; 
  //test: normal * normal = inf and throws overflow flag
  correct_result = 32'hFF800000;
  #1
  while (done_32 !== 1'b1) #1;
  assert (correct_result == result_32) else display_error;
 
  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11100000000000000000000;
  operand_b = 32'b0_01101110_11000000000000000000000;
  //Result        0_00000000_00000000000000001100010 = 0x62; 
  //test: subnormal * normal = subnormal and throws underflow flag
  correct_result = 32'h62;
  #2
  while (done_32 !== 1'b1) #1;
  assert (correct_result == result_32) else display_error;

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_00000000000000000000000;
  operand_b = 32'b0_00000000_00000000000000000000000;
  //Result    0x0 
  //test : zero * zero = zero
  correct_result = 32'h0;
  #2
  while (done_32 !== 1'b1) #1;
  assert (correct_result == result_32) else display_error;

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11100000000000000000000;
  operand_b = 32'b0_01100110_11000000000000000000000;
  //Result        0 = 0x0 
  //test: subnormal * normal = zero if out of range
  correct_result = 32'h0;
  #2
  while (done_32 !== 1'b1) #1;
  assert (correct_result == result_32) else display_error;

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11111111111111111111111;
  operand_b = 32'b0_00000000_11111111111111111111111;
  //Result        0 = 0x0 
  //test: subnormal * subnormal = zero
  correct_result = 32'h0;
  #2
  while (done_32 !== 1'b1) #1;
  assert (correct_result == result_32) else display_error;

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11111111111111111111111;
  operand_b = 32'b0_11011010_11111111111111111111111;
  //Result        0_01011100_11111111111111111111101 = 0x2E7FFFFD  
  //test: subnormal * normal = normal
  correct_result = 32'h2E7FFFFD;
  #2
  while (done_32 !== 1'b1) #1;
  assert (correct_result == result_32) else display_error;

  rounding_mode = 3'b000;
  operand_a = 32'b0_00100110_11111111100000111111111;
  operand_b = 32'b0_11100110_10011110111110110111111;
  //Result        0_10001110_10011110100101101111110 = 0x474F4B7E 
  //test: normal * normal = normal
  correct_result = 32'h474F4B7E;
  #2
  while (done_32 !== 1'b1) #1;
  assert (correct_result == result_32) else display_error;

  rounding_mode = 3'b000;
  operand_a = 32'b0_11111111_11111111100000111111111;
  operand_b = 32'b0_11100110_10011110111110110111111;
  //Result        invalid 
  //test: invalid throws invalid flag
  #2
  assert (invalid_32 === 1'b1) else $display("Flag error! Expected NV: 1, got NV: %b", invalid_32);
/////////////////////////////////////////////// Double precision (Size = 64) /////////////////////////////////////////////////////////
  precision = 64;

  rounding_mode = 3'b000;
  operand_a = 64'b0_11010110000_1100000010010000000000000001010010010100001101010000;
  operand_b = 64'b0_10111011100_1111111111110101100000000000110101010000000000000000;
  //Result        0_11111111111_0000000000000000000000000000000000000000000000000000 = 0x7FF0000000000000 
  //test: normal * normal = inf and throws overflow flag
  correct_result = 64'h7FF0000000000000;
  #2
  while (done_64 !== 1'b1) #1;
  assert (correct_result == result_64) else display_error;

  rounding_mode = 3'b000;
  operand_a = 64'b0_11111111111_1100000010010000000000000001010010010100001101010000;
  operand_b = 64'b0_10111011100_1111111111110101100000000000110101010000000000000000;
  //Result        invalid
  //test: throws invalid flag
  #2
  assert (invalid_64 === 1'b1) else $display("Flag error! Expected NV: 1, got NV: %b", invalid_64);

  rounding_mode = 3'b010;
  operand_a = 64'b1_10111000111_0110010101000001000101101010000000000011111100100001;
  operand_b = 64'b0_10111011100_1000101010110011010001111110000100010110000010111000;
  //Result        1_11110100101_0001001101101000001011101101001000100001000110100010 = 0xFA513682ED2211A2;
  //test: normal * normal = normal
  correct_result = 64'hFA513682ED2211A2;
  #2
  while (done_64 !== 1'b1) #1;
  assert (correct_result == result_64) else display_error;

  rounding_mode = 3'b000;
  operand_a = 64'b1_00000000000_1110010101000001000101101010000000000011111100100001;
  operand_b = 64'b0_10111011100_1000101010110011010001111110000100010110000010111000;
  //Result        1_00111011110_0110000101110110101110011011001110110111001011100111 = 0x9DE6176B9B3B72E7;
  //test: subnormal * normal = normal
  correct_result = 64'h9DE6176B9B3B72E7;
  #2
  while (done_64 !== 1'b1) #1;
  assert (correct_result == result_64) else display_error;

  rounding_mode = 3'b000;
  operand_a = 64'b1_01111111111_1100000000000000000000000000000000000000000000000000;
  operand_b = 64'b1_01111111111_1110000000000000000000000000000000000000000000000000;
  //Result        0_10000000000_1010010000000000000000000000000000000000000000000000 = 0x400A400000000000;
  //test: normal * normal = normal (exact value)
  correct_result = 64'h400A400000000000;
  #2
  while (done_64 !== 1'b1) #1;
  assert (correct_result == result_64) else display_error;

  $display("Finished, got %2d errors", errors);
  $finish;
end

endmodule