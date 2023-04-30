// Módulo decoder parametrizável n x 2^n bits
module decoder #(
	parameter InputSize = 3 // parâmetro especificando número de bits da entrada do decoder
) (
    input [InputSize - 1:0] data_i, // entrada do decoder
    output reg [(1 << InputSize) - 1:0] data_o // saída do decoder
);

	always @* begin
		data_o = 0;
		data_o[data_i] = 1'b1; 
	end

endmodule