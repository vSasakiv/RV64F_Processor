module multiplier_fp_dp #(
    parameter Size = 32
) (
    input               clk, start_op,
    input               sel_a_operand, 
    input [1:0]         sel_b_operand, sel_operation, 
    input               load_exp_result, load_result, load_underflow, load_inexact, load_overflow,
    input [2:0]         rounding_mode,
    input [Size - 1:0]  operand_a, operand_b,
    output [Size - 1:0] result,
    output              invalid, done, inexact, underflow, overflow, zero
);
localparam ExpSize = (Size == 64) ? 11 : 8;
localparam MantSize = (Size == 64) ? 52 : 23; 
localparam MaxResultBits = (Size == 64) ? 106 : 48;

wire                  cout, result_sign, operation, carry_rounding, is_zero, underflow_op, overflow_op;
wire [Size - 1:0]     result_value;
wire [MantSize - 1:0] mant_a, mant_b;
wire [MantSize:0]     mant_rounded, mant_final;
wire [127:0]          karat_data_o;
wire [ExpSize - 1:0]  exp_a, exp_b, exp_final;
wire [ExpSize:0]      i_a, i_b, exp_result, cla_data_o, cla_data_o_c;
wire [MantSize + 3:0] mant_normalized;

assign exp_a = operand_a[Size - 2:MantSize];
assign exp_b = operand_b[Size - 2:MantSize];
assign result_sign = operand_a[Size - 1] ^ operand_b[Size - 1];
assign invalid = (&exp_a) | (&exp_b);
assign mant_a = operand_a[MantSize - 1:0];
assign mant_b = operand_b[MantSize - 1:0];
assign inexact_value = (~is_zero | (underflow_op & (~|mant_final))) & ~zero;
assign zero = ~|operand_a | ~|operand_b;
assign underflow = underflow_op & (|result[MantSize - 1:0]);
assign overflow = overflow_op & ~underflow_op;

assign mant_final = zero ? {(MantSize + 1){1'b0}} : 
                    (underflow_op) ? mant_rounded >> cla_data_o_c[ExpSize - 1:0] : 
                    mant_rounded & {(MantSize){~overflow}};

assign mant_normalized = (~|exp_a || ~|exp_b) ?  
                         {karat_data_o[MaxResultBits - 2: (MaxResultBits - MantSize - 4)], |karat_data_o[(MaxResultBits - MantSize - 5):0] } : 
                         {karat_data_o[MaxResultBits - 1: (MaxResultBits - MantSize - 3)], |karat_data_o[(MaxResultBits - MantSize - 4):0] };

assign exp_final = underflow_op ? 
                   {(ExpSize){1'b0}} : overflow ? {(ExpSize){1'b1}} : 
                   cla_data_o[ExpSize - 1: 0];

assign result_value = (~|exp_a && ~|exp_b) ? {(Size){1'b0}} : 
                      {result_sign, exp_final, mant_final[MantSize - 1:0]};

mux_2to1 #(.Size(ExpSize + 1)) mux_a_operand (
    .i0    ({1'b0, exp_a}),
    .i1    (exp_result),
    .sel   (sel_a_operand),
    .data_o(i_a)
);

mux_4to1 #(.Size(ExpSize + 1)) mux_b_operand (
    .i0    ({1'b0, exp_b}),
    .i1    ({2'b00, {(ExpSize - 1){1'b1}}}),
    .i2    ({{(ExpSize){1'b0}}, carry_rounding}),
    .i3    ({{(ExpSize){1'b0}}, 1'b1}),
    .sel   (sel_b_operand),
    .data_o(i_b)
);

mux_4to1 #(.Size(1'b1)) mux_operation (
    .i0    (1'b0),
    .i1    (1'b1),
    .i2    (1'b0),
    .i3    (1'b0),
    .sel   (sel_operation),
    .data_o(operation)
);

//Somador principal, usado em diferentes ciclos
cla_adder #(.InputSize(ExpSize + 1)) a0 (
    .a  (i_a),
    .b  (i_b),
    .sub(operation),
    .c_o(cout),
    .s  (cla_data_o)
);

cla_adder #(.InputSize(ExpSize + 1)) complement (
    .a  ({{(ExpSize){1'b0}}, 1'b1}),
    .b  (cla_data_o),
    .sub(1'b1),
    .c_o(),
    .s  (cla_data_o_c)
);

karatsuba_64b karat64 (
    .clk  (clk),
    .start(start_op),
    .a    ({{(63 - MantSize){1'b0}}, |exp_a, mant_a}),
    .b    ({{(63 - MantSize){1'b0}}, |exp_b, mant_b}),
    .done (done),
    .s    (karat_data_o)
); 

register #(.Size(ExpSize + 1)) reg_exp_result (
    .clk   (clk),
    .data_i(cla_data_o),
    .load  (load_exp_result),
    .data_o(exp_result)
); 

register #(.Size(Size)) reg_result (
    .clk   (clk),
    .data_i(result_value),
    .load  (load_result),
    .data_o(result)
); 

register #(.Size(1'b1)) reg_underflow (
    .clk   (clk),
    .data_i(~cout & (~|exp_a | ~|exp_b)),
    .load  (load_underflow),
    .data_o(underflow_op)
); 

register #(.Size(1'b1)) reg_overflow (
    .clk   (clk),
    .data_i(cla_data_o[ExpSize]),
    .load  (load_overflow),
    .data_o(overflow_op)
); 

register #(.Size(1'b1)) reg_inexact (
    .clk   (clk),
    .data_i(inexact_value),
    .load  (load_inexact),
    .data_o(inexact)
); 

rounding #(.Size(Size)) round_unit (
    .rounding_mode  (rounding_mode),
    .real_sign      (result_sign),
    .mant_normalized(mant_normalized),
    .carry_rounding (carry_rounding),
    .is_zero        (is_zero),
    .mant_final     (mant_rounded)
  );

endmodule