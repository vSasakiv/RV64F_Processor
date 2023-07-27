`timescale 1 ns / 100 ps

module karatsuba_18b_tb ();
  logic clk, start;
  logic [17:0] a, b;
  logic [35:0] result;
  logic [35:0] expected;
  logic done;
  integer errors;

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
    $dumpfile("karatsuba.vcd");
    $dumpvars(1000, karatsuba_18b_tb);
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
        $display("Error!: a: %18b, b:%18b, expected: %36b, got: %36b", a, b, expected, result);
      end
    end
    $display("Finished, got %2d errors", errors);
    $finish;
  end

endmodule