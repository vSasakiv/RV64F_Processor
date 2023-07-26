`timescale  1ns / 100ps

/* Testbench para o módulo que conta os zeros à direita de um número
Para vários valores, verifica se a saída do módulo é igual ao esperado */
module trailing_zero_counter_tb ();
    parameter SizeMantissa = 23;
    reg [SizeMantissa + 1:0] mantissa, correct_mantissa;
    wire [$clog2(SizeMantissa + 1) - 1:0] trailing_zeros;
    reg [$clog2(SizeMantissa + 1) - 1:0] correct_trailing_zeros;
    integer errors, i, j, aux;

    task check; 
    input [$clog2(SizeMantissa + 1) - 1:0] expected_trailing_zeros;
        if (trailing_zeros !== expected_trailing_zeros) begin 
            $display ("Error, num %b expected %b, got : %b", mantissa, expected_trailing_zeros, trailing_zeros );
            errors = errors + 1;
        end
    endtask

    trailing_zero_counter #(.SizeMantissa(SizeMantissa)) UUT (
        .mantissa, 
        .trailing_zeros
    );

    initial begin
        errors = 0;
        
        for (j = 0; j < 10000; j++) begin
            mantissa = $urandom;
            aux = 0;
                for (i = 0; i < SizeMantissa + 1; i++) begin
                    if (mantissa[i] == 0) aux++;
                    else i = SizeMantissa;
                end

            correct_trailing_zeros = aux;
            #1
            check(correct_trailing_zeros);
        end
        $display ("Finished, got %2d errors", errors);
        $finish;
    end

endmodule