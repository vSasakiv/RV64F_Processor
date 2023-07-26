`timescale 1 ns / 100 ps

module karatsuba_10b_tb ();
  reg clk, start;
  reg [9:0] a, b;
  wire [19:0] result;
  reg [19:0] expected;
  wire done;

  karatsuba_10b UUT (
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
    $dumpvars(1000, karatsuba_10b_tb);
    for (integer i = 0; i < 1000; i = i + 1) begin
      a = $urandom;
      b = $urandom;
      expected = a*b;
      start = 1'b1;
      #20
      start = 1'b0;
      while (done == 1'b0) #5;
      if (result !== expected) $display("Error!: a: %10b, b:%10b, expected: %20b, got: %20b", a, b, expected, result);
      else $display("Success!: a: %10b, b:%10b, expected: %20b, got: %20b", a, b, expected, result);
    end
    $finish;
  end

endmodule