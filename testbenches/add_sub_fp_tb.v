`timescale  1ns / 100ps

/* Testbench para o somador/subtrator de floating point 
Define o modo de arredondamento, os operandos e a operação e revela o resultado obtido */
module add_sub_fp_tb ();
parameter Size = 64; //Quad, double ou single precision (128, 64 ou 32, respectivamente)
reg [2:0] rounding_mode;
reg sub, start;
reg [Size - 1:0] operand_a;
reg [Size - 1:0] operand_b;
reg clk;
wire [Size - 1:0] result;
wire overflow, inexact, underflow, invalid, done;

initial
    clk = 1; // Clock inicial estabelecido como 1;

always 
    #1 clk = ~clk;

//Módulo testado
add_sub_fp #(.Size(Size)) UUT (
  .clk(clk),
  .rounding_mode(rounding_mode),
  .sub(sub),
  .start(start),
  .operand_a(operand_a),
  .operand_b(operand_b),
  .result(result),
  .overflow(overflow),
  .inexact(inexact),
  .underflow(underflow),
  .invalid(invalid),
  .done(done)
);

//Descomente as linhas da precisão que deseja testar. Não esqueça de alterar o parâmetro Size
initial begin
  #2
  $dumpfile("add_sub_fp.vcd");
  $dumpvars(100, add_sub_fp_tb);
  
  //Inicia FSM
  start = 1'b1;

/////////////////////////////////////////////// Single precision (Size = 32) /////////////////////////////////////////////////////////
  /* 
  rounding_mode = 3'b000;
  sub = 1'b0;
  operand_a = 32'b0_01111101_00000000000000000000000;
  operand_b = 32'b0_10000101_10010000000000000000000;
  //Result        0_10000101_10010001000000000000000 = 0x42C88000;
  #1
  while (done !== 1'b1) #1;

  $display("Result addition: %h", result);
  sub = 1'b1;
  operand_a = 32'b0_10000001_10010001000000000000000;
  operand_b = 32'b0_10000000_11100000000000000000000;
  //Result        0_10000000_01000010000000000000000 = 0x40210000;
  #2
  while (done !== 1'b1) #1;
  $display("Result subtraction: %h", result);

  sub = 1'b0;
  rounding_mode = 3'b010;
  operand_a = 32'b1_10000000_11000000000000000011111;
  operand_b = 32'b1_10000010_11100000000000000001001;
  //Result        1_10000011_00101000000000000001000 = 0xC1940009; 
  #2
  while (done !== 1'b1) #1;
  $display("Result addition: %h", result); 
  */

  ///////////////////////////////////////////////Double precision  (Size = 64) /////////////////////////////////////////////////////////
  
  
  sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b0_01111111111_1000000000000000000000000000000000000000000000000000;
  operand_b = 64'b1_01111111111_1000000000000000000000000000000000000000000000000000;
  //Result        0 = 0x0;
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result);

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_01111111111_1000000000000000000000000000000000000000000000000000;
  operand_b = 64'b1_01111111111_1000000000000000000000000000000000000000000000000000;
  //Result        0_10000000000_1000000000000000000000000000000000000000000000000000 = 0x4008000000000000;
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result);

  sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b0;
  operand_b = 64'b0;
  //Result        0 = 0x0;
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result);

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_00000000000_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_01111111110_0000000000000000000000000000000000000000000000000000;
  //Result        1_01111111110_0000000000000000000000000000000000000000000000000000 = 0xBFE0000000000000;
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result);

  sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b0_11111111110_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_11111111110_0000000000000000000000000000000000000000000000000000;
  //Result        0_11111111111_0000000000000000000000000000000000000000000000000000 = 0x7FF0000000000000;
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result);

  sub = 1'b0;
  rounding_mode = 3'b000;
  operand_a = 64'b0_00000000000_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_00000000001_0000000100000000000000000000000000000000000000000000;
  //Result        0_00000000010_0000000000000000000000000000000000000000000000000000 = 0x0020000000000000;
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result);

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_00000000000_1111111100000000000000000000000000000000000000000001;
  operand_b = 64'b0_00000000001_0000000100000000000000000000000000000000000000000000;
  //Result        1_00000000000_0000000111111111111111111111111111111111111111111111 = 0x80001FFFFFFFFFFF; 
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result);

  sub = 1'b1;
  rounding_mode = 3'b000;
  operand_a = 64'b0_10000101010_0011111111100000010110000000000010000010001001101000;
  operand_b = 64'b1_10000101010_0000000000000000000000000000000000000000000000000000;
  //Result        0_10000101011_0001111111110000001011000000000001000001000100110100 = 0x42B1FF02C0041134;
  #2
  while (done !== 1'b1) #1;
  $display("Result: %h", result); 
 
  $finish;
end

endmodule