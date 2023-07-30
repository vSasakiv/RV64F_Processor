module sqrt_fp #(
  parameter Size = 64
) (
  input clk, start,
	input [Size - 1:0] operand,
	output inexact, invalid,
	output done, 
	output [Size - 1:0] result
);
wire reset, done_sqrt;
wire load_result, load_invalid, load_inexact;

	sqrt_fp_dp #(.Size(Size)) sqrt_dp (
		.clk         (clk),
		.reset       (reset),
		.load_result (load_result),
		.load_invalid(load_invalid),
		.load_inexact(load_inexact),
		.operand     (operand),
		.inexact     (inexact),
		.invalid     (invalid),
		.done_sqrt   (done_sqrt),
		.result      (result)
	);

	sqrt_fp_fsm sqrt_fsm (
		.clk         (clk),
		.start       (start),
		.reset       (reset),
		.load_result (load_result),
		.load_invalid(load_invalid),
		.load_inexact(load_inexact),
		.done_sqrt   (done_sqrt),
		.done        (done)
	);

endmodule