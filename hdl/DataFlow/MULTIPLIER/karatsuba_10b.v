module karatsuba_10b (
  input clk, start,
  input [9:0] a, b,
  output [19:0] s,
  output done
);

  wire load_reg1, load_reg2, load_reg3, load_reg4;
  wire sel_reg1, sel_reg2, sel_reg3, sel_reg4;
  wire [1:0] sel_alu_a, sel_alu_b, shamt;
  wire sel_alu_b2;
  wire sel_mult_a, sel_mult_a2, sel_mult_b, sel_mult_b1;
  wire sub;

  karatsuba_10b_cu control (
    .start       (start),
    .clk         (clk),
    .load_reg1   (load_reg1),
    .load_reg2   (load_reg2),
    .load_reg3   (load_reg3),
    .load_reg4   (load_reg4),
    .sel_reg1    (sel_reg1),
    .sel_reg2    (sel_reg2),
    .sel_reg3    (sel_reg3),
    .sel_reg4    (sel_reg4),
    .sel_alu_a   (sel_alu_a),
    .sel_alu_b   (sel_alu_b),
    .shamt       (shamt),
    .sel_alu_b2  (sel_alu_b2),
    .sel_mult_a  (sel_mult_a),
    .sel_mult_a2 (sel_mult_a2),
    .sel_mult_b  (sel_mult_b),
    .sel_mult_b1 (sel_mult_b1),
    .sub         (sub),
    .done        (done)
  );
  karatsuba_10b_dp datap (
    .clk         (clk),
    .a           (a),
    .b           (b),
    .s           (s),
    .load_reg1   (load_reg1),
    .load_reg2   (load_reg2),
    .load_reg3   (load_reg3),
    .load_reg4   (load_reg4),
    .sel_reg1    (sel_reg1),
    .sel_reg2    (sel_reg2),
    .sel_reg3    (sel_reg3),
    .sel_reg4    (sel_reg4),
    .sel_alu_a   (sel_alu_a),
    .sel_alu_b   (sel_alu_b),
    .shamt       (shamt),
    .sel_alu_b2  (sel_alu_b2),
    .sel_mult_a  (sel_mult_a),
    .sel_mult_a2 (sel_mult_a2),
    .sel_mult_b  (sel_mult_b),
    .sel_mult_b1 (sel_mult_b1),
    .sub         (sub)
  );
endmodule