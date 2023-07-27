`timescale 1 ns / 100 ps

module mult_lut_tb ();
logic [5:0] a, b;
logic [11:0] result;
logic [11:0] expected;
integer errors;

  mult_lut UUT (
    .addr({a, b}),
    .data_o(result)
  );
  
  initial begin
    errors = 0;
    for (integer i = 0; i < 1000; i = i + 1) begin
      a = $urandom;
      b = $urandom;
      expected = a * b;
      assert (result == expected) else begin
        errors += 1;
        $display("Error!: a: %6b, b:%6b, expected: %12b, got: %12b", a, b, expected, result);
      end
    end
    $display ("Finished, got %2d errors", errors);
    $finish;
  end

endmodule