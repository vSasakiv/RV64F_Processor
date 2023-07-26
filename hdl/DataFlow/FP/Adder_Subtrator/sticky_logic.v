/* Módulo que verifica se vai haver um sticky bit se smaller_mantissa for shiftada "expoet_diff" vezes*/
module sticky_logic #( 
    parameter SizeMantissa = 23,
    parameter SizeExponent = 8
) (
    input [SizeExponent - 1:0] exponent_diff,
    input [SizeMantissa - 1:0] smaller_mantissa,
    output sticky 
);
    wire [$clog2(SizeMantissa) - 1:0] trailing_zeros;

    //Calcula quantidade de zeros à direita de smaller_mantissa
    trailing_zero_counter #(.SizeMantissa(SizeMantissa + 1)) tzd (
        .mantissa({smaller_mantissa, 3'b0}),
        .trailing_zeros(trailing_zeros)
    );
    
    /*Se a quantidade de zeros à direita for menor que a quantidade de shifts (exponent_diff)
     e exponent_diff != 0 então há sticky bit
    */
    assign sticky = (trailing_zeros <= exponent_diff & |exponent_diff) ? 1'b1 : 1'b0;

endmodule