`timescale 1 ns / 100 ps

//Testbench do módulo decoder n to 2^n, sendo n definido pelo parâmetro InputSize
module decoder_tb ();
    parameter InputSize = 5; // Parâmetro, modificar para testar diferentes decoders
    reg [InputSize - 1:0] data_i;
    reg [(1 << InputSize) - 1:0] correct_data_o;
    wire [(1 << InputSize) - 1:0] data_o;
    integer errors, i;

    //Task responsável por verificar se o valor obtido é igual ao esperado
    task check;
        input [(1 << InputSize) - 1:0] expected_data_o;
        if (data_o !== expected_data_o) begin 
            $display ("Error, got data_o: %b, expeted: %b", data_o, expected_data_o);
            errors = errors + 1;
        end  
    endtask

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
        check(correct_data_o);
      end

      $display ("Finished, got %2d errors", errors);
      $finish;
    end

endmodule