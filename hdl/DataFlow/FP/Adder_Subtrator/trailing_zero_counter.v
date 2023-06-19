/* Módulo que conta a quantidade de zeros à direita de um número */
module trailing_zero_counter #(
	parameter SizeMantissa = 23
) (
	input [SizeMantissa + 1:0] mantissa,
	output [$clog2(SizeMantissa + 1) - 1:0] trailing_zeros
);
	wire bit_or[0:SizeMantissa + 1];
	wire [$clog2(SizeMantissa + 1) - 1:0] encoder_o;
	reg [SizeMantissa + 1:0] code;

	encoder #(.InputSize(SizeMantissa + 2)) e0 (
		.data_i(code),
		.data_o(encoder_o)
		);

	assign trailing_zeros = (~|mantissa) ? SizeMantissa : encoder_o;

	or o0 (bit_or[0], mantissa[0], 1'b0);

	genvar j;
    generate
        for (j = 1; j < SizeMantissa + 1; j = j + 1) begin : fg
            or oi (bit_or[j], bit_or[j - 1], mantissa[j]);
        end
    endgenerate

	integer i;
	always @* begin
		code = 0;
		for (i = 1; i < SizeMantissa + 1; i = i + 1) begin
			if (bit_or[i] == 1 && bit_or[i - 1] == 0) begin
				code[i] = 1;
			end else if (bit_or[i] == 1 && bit_or[i - 1] == 1) begin
				code[i] = 0;
			end
		end
	end 

endmodule