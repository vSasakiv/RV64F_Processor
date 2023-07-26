`timescale  1ns / 100ps

/*
Testbench para o módulo que calcula os sticky bits
Para vários valores, verifica se a saída do circuito é igual a esperada 
*/
module sticky_logic_tb ();
    parameter SizeMantissa = 23;
    parameter SizeExponent = 8;
    reg [SizeExponent - 1:0] exponent_diff;
    reg [SizeMantissa - 1:0] smaller_mantissa;
    reg [SizeMantissa + 2:0] mantissa_roundbits;
    reg correct_sticky;
    wire sticky; 
    integer errors, i, j, aux;

    sticky_logic #(.SizeMantissa(SizeMantissa), .SizeExponent(SizeExponent)) UUT (
        .exponent_diff,
        .smaller_mantissa,
        .sticky
    );

    task check;
        input expected_sticky; 
        if (sticky !== expected_sticky) begin 
            $display ("Error, mantissa: %b, exp diff: %b, expected %b, got : %b", smaller_mantissa, exponent_diff, expected_sticky, sticky);
            errors = errors + 1;
        end
    endtask

    initial begin
        errors = 0;

        for (j = 0; j <= 10000; j++) begin
            smaller_mantissa = $urandom;
            exponent_diff = $urandom;
            mantissa_roundbits = {smaller_mantissa, 3'b0};
            aux = 0;
            for (i = 0; i < SizeMantissa + 1; i++) begin
                if (mantissa_roundbits[i] == 0) aux++;
                else i = SizeMantissa;
            end
    
            correct_sticky = (exponent_diff >= aux ? 1'b1 : 1'b0);
            #1
            check(correct_sticky);
            //$display ("Mantissa: %b, exp diff: %b, aux: %d correct_sticky: %b sticky: %b", smaller_mantissa, exponent_diff, aux, correct_sticky, sticky);

        end
        $display ("Finished, got %2d errors", errors);
        $finish;
    end
endmodule