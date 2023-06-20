`timescale  1ns / 100ps

module multiplier_fp_tb ();
parameter Size = 32;
reg [2:0] rounding_mode;
reg start, clk;
reg [Size - 1:0] operand_a;
reg [Size - 1:0] operand_b;
wire [Size - 1:0] result;
wire invalid, inexact, underflow, overflow, done;

multiplier_fp #(.Size(Size)) UUT (
  .rounding_mode(rounding_mode),
  .start(start), 
  .clk(clk),
  .operand_a(operand_a),
  .operand_b(operand_b),
  .result(result),
  .invalid(invalid), 
  .inexact(inexact),
  .underflow(underflow),
  .overflow(overflow),
  .done(done)
);

initial
    clk = 1; // Clock inicial estabelecido como 1;

always 
    #1 clk = ~clk;

initial begin
  #2
  $dumpfile("multiplier_fp.vcd");
  $dumpvars(1000, multiplier_fp_tb);

  //Inicia FSM
  start = 1'b1;

/////////////////////////////////////////////// Single precision (Size = 32) /////////////////////////////////////////////////////////
  rounding_mode = 3'b000;
  operand_a = 32'b1_10111111_00000000000000000000000;
  operand_b = 32'b0_11111110_00000000000000000000000;
  //Result        0_11111111_00000000000000000000000 = 0xFF800000; 
  //test: normal * normal = inf and throws overflow flag
  #1
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);
  
  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11100000000000000000000;
  operand_b = 32'b0_01101110_11000000000000000000000;
  //Result        0_00000000_00000000000000001100010 = 0x62; 
  //test: subnormal * normal = subnormal and throws underflow flag
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_00000000000000000000000;
  operand_b = 32'b0_00000000_00000000000000000000000;
  //Result    0x0 
  //test : zero * zero = zero
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11100000000000000000000;
  operand_b = 32'b0_01100110_11000000000000000000000;
  //Result        0 = 0x0 
  //test: subnormal * normal = zero if out of range
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11111111111111111111111;
  operand_b = 32'b0_00000000_11111111111111111111111;
  //Result        0 = 0x0 
  //test: subnormal * subnormal = zero
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 32'b0_00000000_11111111111111111111111;
  operand_b = 32'b0_11011010_11111111111111111111111;
  //Result        0_01011100_11111111111111111111101 = 0x2E7FFFFD  
  //test: subnormal * normal = normal
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 32'b0_00100110_11111111100000111111111;
  operand_b = 32'b0_11100110_10011110111110110111111;
  //Result        0_10001110_10011110100101101111110 = 0x474F4B7E 
  //test: normal * normal = normal
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 32'b0_11111111_11111111100000111111111;
  operand_b = 32'b0_11100110_10011110111110110111111;
  //Result        invalid 
  //test: invalid throws invalid flag
  #2
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

/////////////////////////////////////////////// Double precision (Size = 64) /////////////////////////////////////////////////////////
  /* 
  rounding_mode = 3'b000;
  operand_a = 64'b0_11010110000_1100000010010000000000000001010010010100001101010000;
  operand_b = 64'b0_10111011100_1111111111110101100000000000110101010000000000000000;
  //Result        0_10001110_10011110100101101111110 = 0x474F4B7E 
  //test: normal * normal = inf and throws overflow flag
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 64'b0_11111111111_1100000010010000000000000001010010010100001101010000;
  operand_b = 64'b0_10111011100_1111111111110101100000000000110101010000000000000000;
  //Result        invalid
  //test: throws invalid flag
  #2
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b010;
  operand_a = 64'b1_10111000111_0110010101000001000101101010000000000011111100100001;
  operand_b = 64'b0_10111011100_1000101010110011010001111110000100010110000010111000;
  //Result        1_11110100101_0001001101101000001011101101001000100001000110100010 = 0xFA513682ED2211A2;
  //test: normal * normal = normal
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 64'b1_00000000000_1110010101000001000101101010000000000011111100100001;
  operand_b = 64'b0_10111011100_1000101010110011010001111110000100010110000010111000;
  //Result        1_00111011110_0110000101110110101110011011001110110111001011100111 = 0x9DE6176B9B3B72E7;
  //test: subnormal * normal = normal
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

  rounding_mode = 3'b000;
  operand_a = 64'b1_01111111111_1100000000000000000000000000000000000000000000000000;
  operand_b = 64'b1_01111111111_1110000000000000000000000000000000000000000000000000;
  //Result        0_10000000000_1010010000000000000000000000000000000000000000000000 = 0x400A400000000000;
  //test: normal * normal = normal (exact value)
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h NV: %b NX: %b UF: %b OF: %b", result, invalid, inexact, underflow, overflow);

 */
  $finish;
end

endmodule