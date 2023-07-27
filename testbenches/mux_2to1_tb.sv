/* Testbench para o módulo do multiplexador 2 para 1
Verifica para cada entrada se a saída do módulo é igual a esperada de acordo com o seletor. */
`timescale 1 ns / 100 ps

module mux_2to1_tb ();
parameter Size = 64; // Parâmetro que define a quantidade de bits das entradas
logic sel; 
logic [Size - 1:0] correct_data_o;
logic [Size - 1:0] data_o; // saída do multiplexador
logic [Size - 1:0] i0, i1; // entradas do multiplexador
integer errors;

	task display_error;
		begin
			errors += 1;
			$display ("--Error--");
			$display ("Input 0: %h, input 1: %h, sel: %d", i0, i1, sel);
			$display ("Got value: %h", data_o);
			$display ("Correct value: %h", correct_data_o);
			$display ("--------");
		end
	endtask

	// módulo em teste: mux de 2 entradas de "Size" bits
	mux_2to1 #(.Size(Size)) UUT (
		.sel,
		.i0,
		.i1,
		.data_o
	);

	initial begin
		errors = 0;
		i0 = {$urandom, $urandom};
		i1 = {$urandom, $urandom};

		sel = 1'b0;
		#1
		correct_data_o = i0;
		assert (correct_data_o == data_o) else display_error();

		sel = 1'b1;
		#1
		correct_data_o = i1;
		assert (correct_data_o == data_o) else display_error();

		$display ("Finished, got %2d errors", errors);
		$finish;
	end
    
endmodule