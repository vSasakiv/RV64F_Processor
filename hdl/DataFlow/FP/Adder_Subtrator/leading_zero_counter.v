// Módulo que conta a quantidade de zeros à esquerda de um número 
module leading_zero_counter #(
	parameter SizeMantissa = 23
) (
	input [SizeMantissa + 2:0] mantissa,
	output [$clog2(SizeMantissa + 3) - 1:0] leading_zeros
);
	wire bit_or[0:SizeMantissa + 2];
	wire [$clog2(SizeMantissa + 3) - 1:0] encoder_o;
	reg [SizeMantissa + 2:0] code;

	encoder #(.InputSize(SizeMantissa + 3)) e0 (
		.data_i(code),
		.data_o(encoder_o)
		);

	assign leading_zeros = (~|mantissa) ? SizeMantissa : encoder_o;

	or o0 (bit_or[0], mantissa[SizeMantissa + 2], 1'b0);

	genvar j;
    generate
        for (j = 1; j < SizeMantissa + 3; j = j + 1) begin : fg
            or oi (bit_or[j], bit_or[j - 1], mantissa[SizeMantissa + 2 - j]);
        end
    endgenerate

	integer i;
	always @* begin
		code = 0;
		for (i = 1; i < SizeMantissa + 3; i = i + 1) begin
			if (bit_or[i] == 1 && bit_or[i - 1] == 0) begin
				code[i] = 1;
			end else if (bit_or[i] == 1 && bit_or[i - 1] == 1) begin
				code[i] = 0;
			end
		end
	end 

endmodule