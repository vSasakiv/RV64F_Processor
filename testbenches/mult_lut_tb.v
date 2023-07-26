`timescale 1 ns / 100 ps

module mult_lut_tb ();
  reg [5:0] a, b;
  wire [11:0] result;
  reg [11:0] expected;

  mult_lut UUT (
    .addr({a, b}),
    .data_o(result)
  );
  
  initial begin
    for (integer i = 0; i < 1000; i = i + 1) begin
      a = $urandom;
      b = $urandom;
      expected = a*b;
      if (result !== expected) begin
        $display("Error!: a: %6b, b:%6b, expected: %12b, got: %12b", a, b, expected, result);
      end
      $display("Success!: a: %6b, b:%6b, expected: %12b, got: %12b", a, b, expected, result);
    end
    $finish;
  end

endmodule