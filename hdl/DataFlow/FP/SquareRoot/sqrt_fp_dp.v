module sqrt_fp_dp #(
  parameter Size = 64 //Select the precision: 32 (single), 64 (double) or 128 (quad)
) (
	input clk, reset, load_result, load_invalid, load_inexact,
	input [Size - 1:0] operand,
	output inexact, invalid, done_sqrt,
	output [Size - 1:0] result
);
	localparam ExpSize = (Size == 64) ? 11 : 8;
	localparam MantSize = (Size == 64) ? 52 : 23; 
	localparam SqrtSize = (Size == 64) ? 108 : 50;
	localparam Bias = (Size == 64) ? 1023 : 127;

	wire sign;
	wire [ExpSize - 1:0] expoent;
	wire [MantSize + 1: 0] mantissa, mantissa_normalized;
	wire denormal;
	wire [SqrtSize/2 - 1:0] sqrt_result;
	wire [ExpSize - 1:0] real_expoent, effective_exponent, exponent_normalized, result_exponent;
	wire [MantSize - 1:0] rounded_mantissa, result_mantissa;
	wire is_even;
	wire invalid_i;
	wire is_zero;
	wire is_infinity;
	wire [$clog2(MantSize + 3) - 1:0] leading_zeros;

//////////////////////////////// Decompose ////////////////////////////////

	assign sign = operand[Size - 1];
	assign expoent = operand[Size - 2 : MantSize];
	assign denormal = ~|expoent;
	assign is_zero = denormal & (~|operand[MantSize - 1:0]); 
	assign is_infinity = (&expoent & ~|operand[MantSize - 1:0]) ? 1'b1 : 1'b0;
	assign invalid_i = (sign | (&expoent)) & ~is_infinity; 


	leading_zero_counter #(.SizeMantissa(MantSize)) leading_zero_counter (
		.mantissa     ({1'b0, operand[MantSize - 1:0], 2'b0}),
		.leading_zeros(leading_zeros)
	);

	assign mantissa = denormal & ~leading_zeros[0]?  {1'b0, ~denormal, operand[MantSize - 1:0]} : 
					  is_even ? {1'b0, ~denormal, operand[MantSize - 1:0]} : {1'b0, ~denormal, operand[MantSize - 1:0]} << 1;


//////////////////////////////// Exponent calculation ////////////////////////////////
	assign exponent_normalized = denormal & ~is_zero? expoent + leading_zeros : expoent;

	assign is_even = expoent[0] ? 1'b1 : 1'b0;
	assign real_expoent = exponent_normalized - Bias;

	assign effective_exponent = is_zero?
								{(ExpSize){1'b0}} : expoent[ExpSize - 1] | &expoent[ExpSize - 2:0] ? 
								(real_expoent >> 1) + Bias : 
								denormal ? 
								(((real_expoent ^ {(ExpSize){1'b1}}) + 1) >> 1)  + (!leading_zeros[0]) : 
								(real_expoent >> 1) - 1 ;

//////////////////////////////// Mantissa sqrt ////////////////////////////////

	assign mantissa_normalized = denormal ? mantissa << leading_zeros : mantissa; 

	sqrt #(.Size(SqrtSize)) sqrt_unit (
		.clk    (clk),
		.reset  (reset),
		.operand({mantissa_normalized, {(SqrtSize - MantSize - 2){1'b0}}}),
		.result (sqrt_result),
		.done   (done_sqrt)
	);

//////////////////////////////// Rouding ////////////////////////////////

	assign rounded_mantissa = sqrt_result[0] ? {sqrt_result[SqrtSize/2 - 1:1]} + 1 : {sqrt_result[SqrtSize/2 - 1:1]};

//////////////////////////////// Results ////////////////////////////////
	assign result_mantissa = invalid_i && ~is_zero ? 
	                         (sign & ~&expoent) ? {1'b1 ,{(MantSize - 1){1'b0}}} : {1'b1, operand[MantSize - 2:0]} : 
							 is_infinity ? {(MantSize){1'b0}} : rounded_mantissa;
	assign result_exponent = (invalid_i && ~is_zero) | is_infinity  ? {(ExpSize){1'b1}} : effective_exponent;


	register #(.Size(Size)) reg_result (
		.clk   (clk),
		.data_i({sign, result_exponent, result_mantissa}),
		.load  (load_result),
		.data_o(result)
	);

	register #(.Size(1'b1)) reg_inexact(
		.clk   (clk),
		.data_i(sqrt_result[0]),
		.load  (load_inexact),
		.data_o(inexact)
	);

	register #(.Size(1'b1)) reg_invalid (
		.clk   (clk),
		.data_i(invalid_i),
		.load  (load_invalid),
		.data_o(invalid)
	);

endmodule