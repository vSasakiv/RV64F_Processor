module karatsuba_64b (
  input clk, start,
  input [63:0] a, b,
  output done,
  output [127:0] s
);
  
  wire done1, done2, done3;
  wire start1, start2, start3;
  wire load_reg1, load_reg2, load_reg3;
  wire [1:0] sel_alu_a, sel_alu_b;
  wire sel_alu_a1, sub, shamt;

  karatsuba_64b_cu control (
    .start(start),
    .clk(clk),
    .done1(done1),
    .done2(done2),
    .done3(done3),
    .start1(start1),
    .start2(start2),
    .start3(start3),
    .load_reg1(load_reg1),
    .load_reg2(load_reg2),
    .load_reg3(load_reg3),
    .sel_alu_a(sel_alu_a),
    .sel_alu_b(sel_alu_b),
    .sel_alu_a1(sel_alu_a1),
    .shamt(shamt),
    .sub(sub),
    .done(done)
  );

  karatsuba_64b_dp datap (
    .clk        (clk),
    .a          (a),
    .b          (b),
    .s          (s),
    .done1      (done1),
    .done2      (done2),
    .done3      (done3),
    .start1     (start1),
    .start2     (start2),
    .start3     (start3),
    .load_reg1  (load_reg1),
    .load_reg2  (load_reg2),
    .load_reg3  (load_reg3),
    .sel_alu_a  (sel_alu_a),
    .sel_alu_b  (sel_alu_b),
    .sel_alu_a1 (sel_alu_a1),
    .shamt      (shamt),
    .sub        (sub)
  );

endmodule