`timescale  1ns / 100ps

/* Testbench para o módulo que conta os zeros à esquerda de um número
Para vários valores, verifica se a saída do módulo é igual ao esperado */
module leading_zero_counter_tb ();
    parameter SizeMantissa = 23;
    reg [SizeMantissa + 2:0] mantissa, correct_mantissa;
    wire [$clog2(SizeMantissa + 2) - 1:0] leading_zeros;
    reg [$clog2(SizeMantissa + 2) - 1:0] correct_leading_zero;
    integer errors, i, j, aux;

    task check; 
    input [$clog2(SizeMantissa + 1) - 1:0] expected_leading_zero;
        if (leading_zeros !== expected_leading_zero) begin 
            $display ("Error, num %b expected %d, got : %d", mantissa, expected_leading_zero, leading_zeros);
            errors = errors + 1;
        end
    endtask

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
            check(correct_leading_zero);
        end
        $display ("Finished, got %2d errors", errors);
        $finish;
    end

endmodule