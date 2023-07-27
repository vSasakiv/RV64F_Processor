`timescale  1ns / 100ps

/*
Testbench para o módulo que calcula os sticky bits
Para vários valores, verifica se a saída do circuito é igual a esperada 
*/
module sticky_logic_tb ();
parameter SizeMantissa = 23;
parameter SizeExponent = 8;
logic [SizeExponent - 1:0] exponent_diff;
logic [SizeMantissa - 1:0] smaller_mantissa;
logic [SizeMantissa + 2:0] mantissa_roundbits;
logic correct_sticky;
logic sticky; 
integer errors, i, j, aux;

  sticky_logic #(.SizeMantissa(SizeMantissa), .SizeExponent(SizeExponent)) UUT (
    .exponent_diff,
    .smaller_mantissa,
    .sticky
  );

  initial begin
    errors = 0;

    for (j = 0; j <= 10000; j++) begin
      smaller_mantissa = $urandom;
      exponent_diff = $urandom;
      mantissa_roundbits = {smaller_mantissa, 3'b0};
      aux = 0;
      for (i = 0; i < SizeMantissa + 1; i++) begin
        if (mantissa_roundbits[i] == 0) aux++;
        else i = SizeMantissa;
      end

      correct_sticky = (exponent_diff >= aux ? 1'b1 : 1'b0);
      #1
      assert (correct_sticky == sticky) else begin 
        errors += 1;
        $display ("--Error--");
        $display ("Exponent_diff: %d, smaller_mantissa: %b", exponent_diff, smaller_mantissa);
        $display ("got sticky: %b ", sticky);
        $display ("Correct sticky: %b", correct_sticky);
				$display ("--------");
      end
    end
    $display ("Finished, got %2d errors", errors);
    $finish;
  end
endmodule