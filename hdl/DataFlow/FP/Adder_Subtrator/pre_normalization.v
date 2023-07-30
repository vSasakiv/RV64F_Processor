/*Módulo que lida com as operações realizadas no estado "PRE-NORMALIZATION" do somador/subtrator de FP */
module pre_normalization #(
    parameter Size = 32,
    parameter MantSize = (Size == 64) ? 52 : 23, 
    parameter ExpSize = (Size == 64) ? 11 : 8
) (
    input expa_ge_expb, exp_a_zero, exp_b_zero,
    input [ExpSize - 1:0] exp_data_o_c, data_o, exp_a, exp_b,
    input [Size - 1:0] operand_a, operand_b,
    output [MantSize + 3:0] mant_a, mant_b,
    output [ExpSize - 1:0] effective_expoent
);

wire [ExpSize - 1:0] exp_diff;
wire [MantSize:0] smaller_mantissa, greater_mantissa;
wire [MantSize + 3:0] smaller_mantissa_shifted;

  //Obtém o módulo da diferença dos expoentes
  mux_2to1 #(.Size(ExpSize)) m0 (
    .i0(exp_data_o_c),
    .i1(data_o[ExpSize - 1:0]),
    .sel(expa_ge_expb),
    .data_o(exp_diff)
  );

  //Seleciona o maior expoente
  mux_2to1 #(.Size(ExpSize)) m1 (
    .i0(exp_b),
    .i1(exp_a),
    .sel(expa_ge_expb),
    .data_o(effective_expoent)
  );

  //Seleciona a menor e a maior mantissa, com base se o expoente do operador A é maior ou igual ao do B (expa_ge_expb)
  assign smaller_mantissa = expa_ge_expb ? {exp_b_zero, operand_b[MantSize - 1:0]} : {exp_a_zero, operand_a[MantSize - 1:0]};
  assign greater_mantissa = expa_ge_expb ? {exp_a_zero, operand_a[MantSize - 1:0]} : {exp_b_zero, operand_b[MantSize - 1:0]};

  //Verifica se vai haver um sticky bit, com base na diferença entre os expoentes
  sticky_logic #(.SizeMantissa(MantSize + 1), .SizeExponent(ExpSize)) sl (
    .exponent_diff(exp_diff),
    .smaller_mantissa(smaller_mantissa),
    .sticky(sticky)
  );

  //Shifta a menor mantissa para esquerda na quantidade igual à diferença entre os expoentes
  assign smaller_mantissa_shifted = {smaller_mantissa, 3'b0} >> exp_diff;

  //Constrói as mantissas, adicionando os guard, round e sticky buts.
  assign mant_a = expa_ge_expb ? {greater_mantissa, 3'b0} : {smaller_mantissa_shifted[MantSize + 3:1], sticky};
  assign mant_b = expa_ge_expb ? {smaller_mantissa_shifted[MantSize + 3:1], sticky} : {greater_mantissa, 3'b0};

endmodule