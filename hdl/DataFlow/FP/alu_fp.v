module alu_fp #(
  parameter Size = 32
) (
  input [2:0] rounding_mode,
  input sub, start_add_sub, start_mult, clk,
  input [Size - 1:0] operand_a,
  input [Size - 1:0] operand_b,
  output [Size - 1:0] result,
  output invalid, inexact, underflow, overflow, done
);
  wire done_add_sub, done_mult;
  wire [Size-1:0] result_add_sub, result_mult;
  wire flags_add_sub [3:0];
  wire flags_mult [3:0];
  

  add_sub_fp #(.Size(Size)) add_sub_fp (
    .rounding_mode(rounding_mode),
    .start     (start_add_sub),
    .clk       (clk),
    .sub       (sub),
    .operand_a (operand_a),
    .operand_b (operand_b),
    .result    (result_add_sub),
    .inexact   (flags_add_sub[0]),
    .underflow (flags_add_sub[1]),
    .overflow  (flags_add_sub[2]),
    .invalid   (flags_add_sub[3]),
    .done      (done_add_sub)
  );

  multiplier_fp #(.Size(Size)) mult_fp (
    .rounding_mode(rounding_mode),
    .start     (start_mult),
    .clk       (clk),
    .operand_a (operand_a),
    .operand_b (operand_b),
    .result    (result_mult),
    .inexact   (flags_mult[0]),
    .underflow (flags_mult[1]),
    .overflow  (flags_mult[2]),
    .invalid   (flags_mult[3]),
    .done      (done_mult)
  );

  assign done = done_mult | done_add_sub;
  assign result = (done_add_sub & ~done_mult) ? result_add_sub : result_mult;
  assign inexact   = (done_add_sub & ~done_mult) ? flags_add_sub[0] : flags_mult[0];
  assign underflow = (done_add_sub & ~done_mult) ? flags_add_sub[1] : flags_mult[1];
  assign overflow  = (done_add_sub & ~done_mult) ? flags_add_sub[2] : flags_mult[2];
  assign invalid   = (done_add_sub & ~done_mult) ? flags_add_sub[3] : flags_mult[3];
  
endmodule