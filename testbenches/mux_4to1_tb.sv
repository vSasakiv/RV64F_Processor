/* Testbench para o módulo do multiplexador 4 para 1
Verifica para cada entrada se a saída do módulo é igual a esperada de acordo com o seletor. */
`timescale 1 ns / 100 ps

module mux_4to1_tb ();
parameter Size = 64; // Parâmetro que define a quantidade de bits das entradas
reg [1:0] sel; 
reg [Size - 1:0] correct_data_o;
wire [Size - 1:0] data_o; // saída do multiplexador
reg [Size - 1:0] i0, i1, i2, i3; // entradas do multiplexador
integer errors;

	task display_error;
		begin
			errors += 1;
			$display ("--Error--");
			$display ("Input 0: %h, input 1: %h, input 2: %h, input 3: %h, sel: %d", i0, i1, i2, i3, sel);
			$display ("Got value: %h", data_o);
			$display ("Correct value: %h", correct_data_o);
			$display ("--------");
		end
	endtask

  // módulo em teste: mux de 4 entradas de "Size" bits
	mux_4to1 #(.Size(Size)) UUT (
		.sel, 
		.i0, 
		.i1, 
		.i2, 
		.i3, 
		.data_o
	);

  initial begin
	  errors = 0;
	  i0 = {$urandom, $urandom};
	  i1 = {$urandom, $urandom};
	  i2 = {$urandom, $urandom};
	  i3 = {$urandom, $urandom};

	  sel = 2'b00;
	  #1
	  correct_data_o = i0;
		assert (correct_data_o == data_o) else display_error();

	  sel = 2'b01;
	  #1
	  correct_data_o = i1;
		assert (correct_data_o == data_o) else display_error();

	  sel = 2'b10;
	  #1
	  correct_data_o = i2;
		assert (correct_data_o == data_o) else display_error();

	  sel = 2'b11;
	  #1
	  correct_data_o = i3;
		assert (correct_data_o == data_o) else display_error();

	  $display ("Finished, got %2d errors", errors);
	  $finish;
  end

endmodule