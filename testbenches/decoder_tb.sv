`timescale 1 ns / 100 ps

//Testbench do módulo decoder n to 2^n, sendo n definido pelo parâmetro InputSize
module decoder_tb ();
parameter InputSize = 5; // Parâmetro, modificar para testar diferentes decoders
reg [InputSize - 1:0] data_i;
reg [(1 << InputSize) - 1:0] correct_data_o;
wire [(1 << InputSize) - 1:0] data_o;
integer errors, i;

  //Módulo testado
	decoder #(InputSize) UUT (
  	.data_i,
	  .data_o
  );

  //Para todos os valores possíveis de data_i, define um valor correto e verifica se é igual ao recebido do módulo
  initial begin
    errors = 0;

    for (i = 0; i < InputSize; i++) begin
      correct_data_o = 1'b0;
      data_i = i;
      correct_data_o[data_i] = 1'b1;
      #1
			assert (correct_data_o == data_o) else begin
				errors += 1;
				$display ("--Error--");
        $display ("data_i: %d", data_i);
        $display ("got value: %b", data_o);
        $display ("Correct value: %b", correct_data_o);
		    $display ("--------");
			end
    end

    $display ("Finished, got %2d errors", errors);
    $finish;
  end

endmodule