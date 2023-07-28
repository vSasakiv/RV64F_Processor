module sqrt #(
  parameter Size = 32
) (
	input clk, reset,
	input [Size - 1:0] operand,
	output done,
	output [Size/2 - 1:0] result
);

	reg [Size/2 - 1: 0] tmp_a;
	reg [Size - 1:0] tmp_b;
	reg [$clog2(Size) - 1:0] bitindex;
	wire [Size/2 - 1:0] bit_a = 1 << bitindex;
	wire [Size - 1:0] bit_b = 1 << (bitindex << 1);

	assign done = bitindex[$clog2(Size) - 1];
	assign result = tmp_a;

	wire [Size/2 - 1:0] guess_a = tmp_a | bit_a;
	wire [Size - 1:0] guess_b = tmp_b + bit_b + ((tmp_a << bitindex) << 1);

	always @(reset or posedge clk) begin 
		if (reset) begin
			tmp_a = 0;
			tmp_b = 0;
			bitindex = {1'b0, {($clog2(Size) - 1){1'b1}}};
		end else begin 
			if (guess_b <= operand) begin 
				tmp_a = guess_a;
				tmp_b = guess_b;
			end
			bitindex = bitindex - 1;
		end
	end

endmodule