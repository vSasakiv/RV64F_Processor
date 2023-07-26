`timescale 1 ns / 100 ps

module karatsuba_18b_tb ();
  reg clk, start;
  reg [17:0] a, b;
  wire [35:0] result;
  reg [35:0] expected;
  wire done;

  karatsuba_18b UUT (
    .clk   (clk),
    .start (start),
    .a     (a),
    .b     (b),
    .s     (result),
    .done  (done)
  );
  

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    start = 0;
    $dumpfile("karatsuba.vcd");
    $dumpvars(1000, karatsuba_18b_tb);
    for (integer i = 0; i < 1000; i = i + 1) begin
      a = $urandom;
      b = $urandom;
      expected = a*b;
      start = 1'b1;
      #20
      start = 1'b0;
      while (done == 1'b0) #5;
      if (result !== expected) $display("Error!: a: %18b, b:%18b, expected: %36b, got: %36b", a, b, expected, result);
      else $display("Success!: a: %18b, b:%18b, expected: %36b, got: %36b", a, b, expected, result);
    end
    $finish;
  end

endmodule