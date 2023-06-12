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

    // Task responsável por checar se a saída do módulo é igual ao valor esperado
    task check;
        input [Size - 1:0] expected_data_o;
        if (data_o !== expected_data_o) begin 
            $display ("Error, data_o: %32b, expected: %32b", data_o, expected_data_o); 
            errors = errors + 1;
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
        i0 = $urandom & 8'b11111111;
        i1 = $urandom & 8'b11111111;
        i2 = $urandom & 8'b11111111;
        i3 = $urandom & 8'b11111111;

        sel = 2'b00;
        #1
        correct_data_o = i0;
        check (correct_data_o);

        sel = 2'b01;
        #1
        correct_data_o = i1;
        check (correct_data_o);

        sel = 2'b10;
        #1
        correct_data_o = i2;
        check (correct_data_o);

        sel = 2'b11;
        #1
        correct_data_o = i3;
        check (correct_data_o);

        $display ("Finished, got %2d errors", errors);
        $finish;
    end

endmodule