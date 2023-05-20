/* Testebench para o módulo do registrador de n bits, sendo "n" decidido pelo parâmetro Size.
Verifica, para 1000 valores aleatórios de data_i, se a cada borda positiva no módulo:
1 - A saída for 0 quando reset for 1
2 - A saída é igual a entrada se reset = 0 e load = 1
3 - A saída permanece igual a anterior caso reset = 0 e load = 0 */
`timescale 1 ns / 100 ps

module reg_async_reset_tb ();
    parameter Size = 64; // Parâmetro que define o tamanho do registrador (quantidade de bits guardados)
    reg clk; 
    reg reset; 
    reg load; 
    reg [Size - 1:0] correct_data_o; 
    reg [Size - 1:0] data_i; // entrada do registrador
    wire [Size - 1:0] data_o; // saída do registrador
    integer errors, i;

    initial
        clk = 1; // Clock inicial estabelecido como 1;

    always 
        #1 clk = ~clk;

    //Módulo testado 
    reg_async_reset #(.Size(Size)) UUT (
        .clk, 
        .data_i, 
        .reset, 
        .load, 
        .data_o);

    // Task responsável por checar se a saída do módulo é igual ao valor esperado
    task check;
        input [Size - 1:0] expected_data_o;
        if (data_o !== expected_data_o) begin 
            $display ("Error, data_o: %b, expeted: %b", data_o, expected_data_o);  // ***Alterar a quantidade de bits para corresponder ao Size ***
            errors = errors + 1;
        end 
    endtask

    initial begin
        errors = 0;

        for (i = 0; i < 1000; i++) begin
            data_i = $urandom; // ***Alterar a quantidade de bits para corresponder ao Size ***
            reset = 1;

            #2 
            correct_data_o = 0;
            check (correct_data_o); // Verifica se a saída é 0 quando reset for 1

            reset = 0;
            load = 1;
            
            #2 
            correct_data_o = data_i; 
            check (correct_data_o); // Verifica se a saída é igual a entrada se reset = 0 e load = 1

            load = 0;
            correct_data_o = data_i;
            data_i = $urandom; 
            
            #2
            check (correct_data_o); // Verifica se a  saída permanece igual a anterior caso reset = 0 e load = 0
        end

        $display ("Finished, got %2d errors", errors);
        $finish;
    end

endmodule    