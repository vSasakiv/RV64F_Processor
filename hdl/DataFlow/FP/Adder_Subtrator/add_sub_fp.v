/* Top level module: Somador/subtrator de números floating point */
module add_sub_fp #(
  parameter Size = 32
) (
  input [2:0] rounding_mode,
  input sub, start, clk,
  input [Size - 1:0] operand_a,
  input [Size - 1:0] operand_b,
  output [Size - 1:0] result,
  output overflow, inexact, underflow, invalid, done
);

  wire [1:0]  sel_a_exp_operand, sel_b_exp_operand, sel_exp_operation; 
  wire sel_a_operand, sel_b_operand, sel_operation;
  wire load_mant_a, load_mant_b, load_mant_shifted, load_mant_normalized, load_effective_expoent, load_expoent_result;
  wire load_exp_normalized, load_invalid, load_carry, load_real_operation, load_real_sign, load_underflow;
  wire load_leading_zeros, load_result, load_overflow, load_inexact, load_out_of_precision, load_expa_ge_expb;
  wire out_of_precision;

  add_sub_fsm fsm (  
    .start                 (start), 
    .clk                   (clk),
    .sel_a_exp_operand     (sel_a_exp_operand),
    .sel_b_exp_operand     (sel_b_exp_operand),
    .sel_exp_operation     (sel_exp_operation),
    .sel_a_operand         (sel_a_operand),
    .sel_b_operand         (sel_b_operand),
    .sel_operation         (sel_operation),
    .load_mant_a           (load_mant_a),
    .load_mant_b           (load_mant_b),
    .load_mant_shifted     (load_mant_shifted),
    .load_mant_normalized  (load_mant_normalized),
    .load_effective_expoent(load_effective_expoent),
    .load_expoent_result   (load_expoent_result),
    .load_exp_normalized   (load_exp_normalized),
    .load_carry            (load_carry),
    .load_real_operation   (load_real_operation),
    .load_real_sign        (load_real_sign),
    .load_underflow        (load_underflow),
    .load_leading_zeros    (load_leading_zeros),
    .load_result           (load_result),
    .load_overflow         (load_overflow),
    .load_inexact          (load_inexact),
    .load_out_of_precision (load_out_of_precision),
    .load_expa_ge_expb     (load_expa_ge_expb),
    .out_of_precision      (out_of_precision),
    .done                  (done)
  );

  add_sub_dp #(.Size(Size)) dp (
    .clk                   (clk),
    .sel_a_exp_operand     (sel_a_exp_operand),
    .sel_b_exp_operand     (sel_b_exp_operand),
    .sel_exp_operation     (sel_exp_operation),
    .sel_a_operand         (sel_a_operand),
    .sel_b_operand         (sel_b_operand),
    .sel_operation         (sel_operation),
    .load_mant_a           (load_mant_a),
    .load_mant_b           (load_mant_b),
    .load_mant_shifted     (load_mant_shifted),
    .load_mant_normalized  (load_mant_normalized),
    .load_effective_expoent(load_effective_expoent),
    .load_expoent_result   (load_expoent_result),
    .load_exp_normalized   (load_exp_normalized),
    .load_carry            (load_carry),
    .load_real_operation   (load_real_operation),
    .load_real_sign        (load_real_sign),
    .load_underflow        (load_underflow),
    .load_leading_zeros    (load_leading_zeros),
    .load_result           (load_result),
    .load_overflow         (load_overflow),
    .load_inexact          (load_inexact),
    .load_out_of_precision (load_out_of_precision),
    .load_expa_ge_expb     (load_expa_ge_expb),
    .rounding_mode         (rounding_mode),
    .sub                   (sub),
    .operand_a             (operand_a),
    .operand_b             (operand_b),
    .out_of_precision      (out_of_precision),
    .result_value          (result),
    .overflow_value        (overflow),
    .inexact_value         (inexact),
    .underflow_value       (underflow),
    .invalid               (invalid)
  );

endmodule