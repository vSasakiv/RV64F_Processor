/* Testebench para o módulo do registrador de n bits, sendo "n" decidido pelo parâmetro Size.
Verifica, para 1000 valores aleatórios de data_i, se a cada borda positiva no módulo:
1 - A saída é igual a entrada se reset = 0 e load = 1
2 - A saída permanece igual a anterior load = 0 */
`timescale 1 ns / 100 ps

module register_tb ();
parameter Size = 32; // Parâmetro que define o tamanho do registrador (quantidade de bits guardados)
logic clk; 
logic load; 
logic [Size - 1:0] correct_data_o; 
logic [Size - 1:0] data_i; // entrada do registrador
logic [Size - 1:0] data_o; // saída do registrador
integer errors, i;

	initial
		clk = 1; // Clock inicial estabelecido como 1;

	always 
		#1 clk = ~clk;

	//Módulo testado 
  register #(.Size(Size)) UUT (
      .clk, 
      .data_i, 
      .load, 
      .data_o
  );

    // Task responsável por checar se a saída do módulo é igual ao valor esperado
    task check;
        input [Size - 1:0]expected_data_o;
        if (data_o !== expected_data_o) begin 
            $display ("Error, data_o: %32b, expeted: %32b", data_o, expected_data_o);  // ***Alterar a quantidade de bits para corresponder ao Size ***
            errors = errors + 1;
        end 
    endtask
	
	task display_error;
		begin
			errors += 1;
      $display ("--Error--");
      $display ("Data_i: %h", data_i);
      $display ("Got data_o: %h", data_o);
      $display ("Correct data_o: %h", correct_data_o);
		  $display ("--------");
		end
	endtask

	initial begin
  	errors = 0;

  	for (i = 0; i < 1000; i++) begin
      	data_i = $urandom; // ***Alterar a quantidade de bits para corresponder ao Size ***
      	load = 1;	            
      	#2 
      	correct_data_o = data_i;
				assert (correct_data_o == data_o) else display_error(); // Verifica se a saída é igual a entrada se load = 1

      	load = 0;
      	correct_data_o = data_i;
      	data_i = $urandom;	            
      	#2
      	assert (correct_data_o == data_o) else display_error(); // Verifica se a  saída permanece igual a anterior caso load = 0
  	end

  	$display ("Finished, got %2d errors", errors);
  	$finish;
	end

endmodule    