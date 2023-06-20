module multiplier_fp #(
  parameter Size = 32
) (
  input [2:0] rounding_mode,
  input start, clk,
  input [Size - 1:0] operand_a,
  input [Size - 1:0] operand_b,
  output [Size - 1:0] result,
  output invalid, inexact, underflow, overflow, done
);
wire done_karat, done_fsm, start_op, zero;
wire sel_a_operand;
wire [1:0] sel_b_operand, sel_operation;
wire load_exp_result, load_result, load_underflow, load_overflow;

  multiplier_fp_fsm mult_fsm (
    .start          (start),
    .clk            (clk),
    .done_karat     (done_karat),
    .sel_a_operand  (sel_a_operand), 
    .sel_b_operand  (sel_b_operand),
    .sel_operation  (sel_operation),
    .load_exp_result(load_exp_result),
    .load_result    (load_result),
    .load_underflow (load_underflow),
    .load_inexact   (load_inexact),
    .load_overflow  (load_overflow),
    .invalid        (invalid),
    .zero           (zero),
    .done_fsm       (done),
    .start_op       (start_op)
  );

  multiplier_fp_dp #(.Size(Size)) mult_dp (
    .clk            (clk),
    .start_op       (start_op),
    .sel_a_operand  (sel_a_operand),
    .sel_b_operand  (sel_b_operand),
    .sel_operation  (sel_operation),
    .load_exp_result(load_exp_result),
    .load_result    (load_result),
    .load_inexact   (load_inexact),
    .load_overflow  (load_overflow),
    .rounding_mode  (rounding_mode),
    .operand_a      (operand_a),
    .operand_b      (operand_b),
    .result         (result),
    .invalid        (invalid),
    .done           (done_karat),
    .load_underflow (load_underflow),
    .inexact        (inexact),
    .underflow      (underflow),
    .overflow       (overflow),
    .zero           (zero)
  );

endmodule