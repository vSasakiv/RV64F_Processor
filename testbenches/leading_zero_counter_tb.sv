`timescale  1ns / 100ps

/* Testbench para o módulo que conta os zeros à esquerda de um número
Para vários valores, verifica se a saída do módulo é igual ao esperado */
module leading_zero_counter_tb ();
parameter SizeMantissa = 23;
logic [SizeMantissa + 2:0] mantissa, correct_mantissa;
logic [$clog2(SizeMantissa + 2) - 1:0] leading_zeros;
logic [$clog2(SizeMantissa + 2) - 1:0] correct_leading_zero;
integer errors, i, j, aux;

	leading_zero_counter #(.SizeMantissa(SizeMantissa)) UUT (
		.mantissa, 
		.leading_zeros
	);

initial begin
	errors = 0;

	for (j = 0; j < 10000; j++) begin
		mantissa = $urandom;
		aux = 0;
		for (i = SizeMantissa + 2; i > 0; i--) begin
			if (mantissa[i] == 0) aux++;
			else i = 0;
		end

		correct_leading_zero = aux;
		#1
		assert (correct_leading_zero == leading_zeros) else begin
			 	errors += 1;
        $display ("--Error--");
        $display ("Mantissa: %b", mantissa);
        $display ("got value: %d", leading_zeros);
        $display ("Correct value:", correct_leading_zero);
				$display ("--------");
		end
	end
	$display ("Finished, got %2d errors", errors);
	$finish;
end

endmodule