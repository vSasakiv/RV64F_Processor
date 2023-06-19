/* Datapath do somador/subtrator de FP */
module add_sub_dp #(
    parameter Size = 32 //Quad, double ou single precision (128, 64 ou 32, respectivamente)
) (
    input clk,
    input [1:0] sel_a_exp_operand, sel_b_exp_operand, sel_exp_operation,
    input sel_a_operand, sel_b_operand, sel_operation,
    input load_mant_a, load_mant_b, load_mant_shifted, load_mant_normalized,
    input load_effective_expoent, load_expoent_result, load_exp_normalized,
    input load_invalid, load_carry, load_real_operation, load_real_sign, load_underflow,
    input load_leading_zeros, load_result,
    input [2:0] rounding_mode,
    input sub, // 0 -> adição; 1 -> subtração
    input [Size - 1:0] operand_a,
    input [Size - 1:0] operand_b,
    output [Size - 1:0] result_value,
    output overflow, inexact, underflow_value, invalid
);
localparam ExpSize = (Size == 64) ? 11 : 8;
localparam MantSize = (Size == 64) ? 52 : 23; 

wire underflow;
wire [MantSize + 3:0] mant_a_value, mant_b_value, mant_shifted_value, mant_normalized_value;
wire [ExpSize - 1:0] effective_expoent_value, expoent_result_value, exp_normalized_value;
wire carry_value, real_operation_value, real_sign_value;
wire [$clog2(MantSize + 4) - 1:0] leading_zeros_value;
wire [Size - 1:0] result;

wire sign_a, sign_b, real_operation, real_sign, operation, exp_operation;
wire is_zero, exp_a_zero, exp_b_zero;
wire carry_rounding, cout;
wire [ExpSize - 1:0] exp_data_o_c, effective_expoent, expoent_result, exp_normalized,  normalize_shift_amt; 
wire [ExpSize - 1:0] exp_a, exp_b, exp_a_operand, exp_b_operand;
wire [MantSize:0]  mant_final;
wire [MantSize + 3:0] i_a, i_b, data_o, data_o_c, mant_a, mant_b, mant_shifted, mant_normalized;
wire [$clog2(MantSize + 4) - 1:0] leading_zeros;

//Sinais dos operandos
assign sign_a = operand_a[Size - 1]; 
assign sign_b = operand_b[Size - 1];

//Guarda informação se o expoente não é igual a 0
assign exp_a_zero = |operand_a[Size - 2:MantSize];
assign exp_b_zero = |operand_b[Size - 2:MantSize];

// O expoente usado é 1 caso seja subnormal e o valor do expoente no operando caso contrário.
assign exp_a = ~exp_a_zero ? 1'b1 : operand_a[Size - 2:MantSize];
assign exp_b = ~exp_b_zero ? 1'b1 : operand_b[Size - 2:MantSize];

//Sobe flag invalid se algum dos expoentes for o maior possível (todos bits = 1)
assign invalid = (&operand_a[Size - 2:MantSize]) | (&operand_b[Size - 2:MantSize]);

  //Seleciona qual valor será direcionado para o primeiro mux do somador/subtrator principal
  mux_4to1 #(.Size(ExpSize)) mux_a_exp (
    .i0(exp_a),
    .i1(effective_expoent_value),
    .i2(expoent_result_value),
    .i3(exp_normalized_value),
    .sel(sel_a_exp_operand),
    .data_o(exp_a_operand)
  );

  //Seleciona o valor do primeiro operando do somador/subtrator principal
  mux_2to1 #(.Size(MantSize + 4)) mux_a_operand (
    .i0({{(MantSize + 4 - ExpSize){1'b0}}, exp_a_operand}),
    .i1(mant_a_value),
    .sel(sel_a_operand),
    .data_o(i_a)
  );

  //Seleciona qual valor será direcionado para o segundo mux do somador/subtrator principal
  mux_4to1 #(.Size(ExpSize)) mux_b_exp (
    .i0(exp_b),
    .i1({{(ExpSize - 1){1'b0}}, 1'b1}),
    .i2(normalize_shift_amt),
    .i3({{(ExpSize - 1){1'b0}}, carry_rounding}),
    .sel(sel_b_exp_operand),
    .data_o(exp_b_operand)
  );
  
  //Seleciona o valor do segundo operando do somador/subtrator principal
  mux_2to1 #(.Size(MantSize + 4)) mux_b_operand (
    .i0({{(MantSize + 4 - ExpSize){1'b0}}, exp_b_operand}),
    .i1(mant_b_value),
    .sel(sel_b_operand),
    .data_o(i_b)
  );

  //Seleciona qual operação será direcionada para o mux do somador/subtrator principal
  mux_4to1 #(.Size(1'b1)) mux_exp_operation (
    .i0(1'b1),
    .i1(1'b0),
    .i2(1'b1),
    .i3(1'b0),
    .sel(sel_exp_operation),
    .data_o(exp_operation)
  );

  //Seleciona qual é a operação realizada no somador/subtrator principal
  mux_2to1 #(.Size(1'b1)) mux_operation (
    .i0(exp_operation),
    .i1(real_operation),
    .sel(sel_operation),
    .data_o(operation)
  );

  //Somador principal, usado em diferentes ciclos
  cla_adder #(.InputSize(MantSize + 4)) a0 (
    .a(i_a),
    .b(i_b),
    .sub(operation),
    .c_o(cout),
    .s(data_o)
  );

  //Complemente o resultado do somador principal com tamanho do expoente
  cla_adder #(.InputSize(ExpSize)) complement0 (
    .a({(ExpSize){1'b0}}),
    .b(data_o[ExpSize - 1:0]),
    .sub(1'b1),
    .c_o(),
    .s(exp_data_o_c)
  );

  //Complemente o resultado do somador principal com tamanho da mantissa aumentada
  cla_adder #(.InputSize(MantSize + 4)) complement1 (
    .a({(MantSize + 4){1'b0}}),
    .b(data_o),
    .sub(1'b1),
    .c_o(),
    .s(data_o_c)
  );


//////////////////////////////// Pre-normalization ////////////////////////////////

  pre_normalization #(.Size(Size)) pre_norm (
    .expa_ge_expb(cout),
    .exp_a_zero(exp_a_zero),
    .exp_b_zero(exp_b_zero),
    .exp_data_o_c(exp_data_o_c),
    .data_o(data_o[ExpSize - 1:0]),
    .exp_a(exp_a),
    .exp_b(exp_b),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .mant_a(mant_a),
    .mant_b(mant_b),
    .effective_expoent(effective_expoent)
  );

  register #(.Size(MantSize + 4)) reg_mant_a (
    .clk(clk),
    .data_i(mant_a),
    .load(load_mant_a),
    .data_o(mant_a_value)
  );

  register #(.Size(MantSize + 4)) reg_mant_b (
    .clk(clk),
    .data_i(mant_b),
    .load(load_mant_b),
    .data_o(mant_b_value)
  );

  register #(.Size(ExpSize)) reg_effective_expoent (
    .clk(clk),
    .data_i(effective_expoent),
    .load(load_effective_expoent),
    .data_o(effective_expoent_value)
  );

//////////////////////////////// OPERATION ////////////////////////////////

  operation #(.Size(Size)) op (
    .operand_a(operand_a),
    .operand_b(operand_b),
    .sub(sub),
    .sign_a(sign_a),
    .sign_b(sign_b),
    .carry(cout),
    .data_o(data_o),
    .data_o_c(data_o_c),
    .leading_zeros(leading_zeros),
    .mant_shifted (mant_shifted),
    .real_operation(real_operation),
    .real_sign(real_sign)
  );

  register #(.Size(1'b1)) reg_carry (
    .clk(clk),
    .data_i(cout),
    .load(load_carry),
    .data_o(carry_value)
  );

  register #(.Size($clog2(MantSize + 4))) reg_leading_zeros (
    .clk(clk),
    .data_i(leading_zeros),
    .load(load_leading_zeros),
    .data_o(leading_zeros_value)
  );

    register #(.Size(MantSize + 4)) reg_mant_shifted (
    .clk(clk),
    .data_i(mant_shifted),
    .load(load_mant_shifted),
    .data_o(mant_shifted_value)
  );

  register #(.Size(1'b1)) reg_real_operation (
    .clk(clk),
    .data_i(real_operation),
    .load(load_real_operation),
    .data_o(real_operation_value)
  );

  register #(.Size(1'b1)) reg_real_sign (
    .clk(clk),
    .data_i(real_sign),
    .load(load_real_sign),
    .data_o(real_sign_value)
  );


//////////////////////////////// Normalizing ////////////////////////////////

  /* Verifica se vai ocorrer undeflow (expoente <= 0) e atribui o expoente zero se sim. 
  Caso não ocorra, se houve carry com uma operação de soma, usa o effective_expoent + 1, caso contrário se mantém o valor do effective_expoent.
  */
  assign expoent_result = (leading_zeros_value >= effective_expoent_value) ? {(ExpSize){1'b0}}: (carry_value & (~real_operation_value)) ? data_o[ExpSize - 1:0]: effective_expoent_value;
  
  //Se o expoente resultante for != 0, shifta a mantissa pela quantidade de leading zeros, mantém o mesmo valor caso contrário.
  assign mant_normalized =  (~|expoent_result) ? mant_shifted_value : mant_shifted_value << leading_zeros_value;

  register #(.Size(ExpSize)) reg_expoent_result (
    .clk(clk),
    .data_i(expoent_result),
    .load(load_expoent_result),
    .data_o(expoent_result_value)
  );

  register #(.Size(MantSize + 4)) reg_mant_normalized (
    .clk(clk),
    .data_i(mant_normalized),
    .load(load_mant_normalized),
    .data_o(mant_normalized_value)
  );

//////////////////////////////// Shifting Expoent ////////////////////////////////

  /* Se a mantissa for = 0,  assume valor do expoente.
  Caso não seja, se o expoente atual for subnormal assume 0, caso contrário é igual aos leading zeros */
  assign normalize_shift_amt = (~|mant_normalized_value) ? expoent_result_value : (~|expoent_result_value) ? 1'b0: leading_zeros_value;
  assign underflow = data_o[ExpSize];

  register #(.Size(ExpSize)) reg_exp_normalized (
    .clk(clk),
    .data_i(data_o[ExpSize - 1:0]),
    .load(load_exp_normalized),
    .data_o(exp_normalized_value)
  );

  register #(.Size(1'b1)) reg_underflow (
    .clk(clk),
    .data_i(underflow),
    .load(load_underflow),
    .data_o(underflow_value)
  );

//////////////////////////////// ROUNDING ////////////////////////////////

  rounding #(.Size(Size)) round_unit (
    .rounding_mode(rounding_mode),
    .real_sign(real_sign_value),
    .mant_normalized(mant_normalized_value),
    .carry_rounding(carry_rounding),
    .is_zero(is_zero),
    .mant_final(mant_final)
  );

  assign inexact = ~is_zero;
  assign overflow = (&data_o[ExpSize - 1:0]) ? 1'b1 : 1'b0;
  assign result = (overflow) ? {real_sign_value, data_o[ExpSize - 1:0], {(MantSize){1'b0}}} : {real_sign_value, data_o[ExpSize - 1:0], mant_final[MantSize - 1:0]};

  register #(.Size(Size)) reg_result (
    .clk(clk),
    .data_i(result),
    .load(load_result),
    .data_o(result_value)
  );

endmodule