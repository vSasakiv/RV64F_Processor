`timescale 1 ns / 100 ps

module karatsuba_10b_tb ();
  logic clk, start;
  logic [9:0] a, b;
  logic [19:0] result;
  logic [19:0] expected;
  logic done;
  integer errors;

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
    $dumpfile("karatsuba.vcd");
    $dumpvars(1000, karatsuba_10b_tb);
    errors = 0;
    clk = 0;
    start = 0;
    
    for (integer i = 0; i < 1000; i = i + 1) begin
      a = $urandom;
      b = $urandom;
      expected = a * b;
      start = 1'b1;
      #20
      start = 1'b0;
      while (done == 1'b0) #5;
      assert (expected == result) else begin
        errors += 1;
        $display("Error!: a: %10b, b:%10b, expected: %20b, got: %20b", a, b, expected, result);
      end
    end
    $display("Finished, got %2d errors", errors);
    $finish;
  end

endmodule