module decoder #(
	parameter InputSize = 3
) (
    input [InputSize - 1:0] data_i,
    output reg [(1 << InputSize) - 1:0] data_o
);

	always @* begin
		data_o = 0;
		data_o[data_i] = 1'b1; 
	end

endmodule