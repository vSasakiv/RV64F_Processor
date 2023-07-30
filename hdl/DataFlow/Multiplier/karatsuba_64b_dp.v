module karatsuba_64b_dp (
  input clk, start1, start2, start3, shamt, sub,
  input load_reg1, load_reg2, load_reg3, sel_alu_a1,
  input [1:0] sel_alu_a, sel_alu_b,
  input [63:0] a, b,
  output done1, done2, done3,
  output [127:0] s
);

  wire [67:0] kara1_o, kara2_o, kara3_o;
  wire [127:0] alu_a1s;
  wire [127:0] alu_a, alu_b, adder_o;
  wire [65:0] reg3_o;
  wire [63:0] reg1_o, reg2_o;
  wire [65:0] alu_a1;
  wire [127:0] reg3s;

  karatsuba_34b kara1 (
    .clk   (clk),
    .start (start1),
    .a     ({2'b0, a[63:32]}),
    .b     ({2'b0, b[63:32]}),
    .s     (kara1_o),
    .done  (done1)
  );

  karatsuba_34b kara2 (
    .clk   (clk),
    .start (start2),
    .a     ({2'b0, a[31:0]}),
    .b     ({2'b0, b[31:0]}),
    .s     (kara2_o),
    .done  (done2)
  );

  karatsuba_34b kara3 (
    .clk   (clk),
    .start (start3),
    .a     ({1'b0, reg2_o[32:0]}),
    .b     ({1'b0, adder_o[32:0]}),
    .s     (kara3_o),
    .done  (done3)
  );

  register #(.Size(64)) rout1 (
    .clk    (clk),
    .data_i (adder_o[127:64]),
    .data_o (reg1_o),
    .load   (load_reg1)
  );

  register #(.Size(64)) rout2(
    .clk    (clk),
    .data_i (adder_o[63:0]),
    .data_o (reg2_o),
    .load   (load_reg2)
  );

  register #(.Size(66)) rout3 (
    .clk    (clk),
    .data_i (adder_o[65:0]),
    .data_o (reg3_o),
    .load   (load_reg3)
  );

  cla_adder #(.InputSize(128)) add0 (
    .a   (alu_a),
    .b   (alu_b),
    .c_o (),
    .sub (sub),
    .s   (adder_o)
  );

  mux_4to1 #(.Size(128)) mux1 (
    .sel    (sel_alu_a),
    .i0     ({96'b0, a[63:32]}),
    .i1     ({96'b0, b[63:32]}),
    .i2     (alu_a1s),
    .i3     ({reg1_o, reg2_o}),
    .data_o (alu_a)
  );

  assign alu_a1s = shamt ? {62'b0, alu_a1} << 64 : {62'b0, alu_a1};

  mux_2to1 #(.Size(66)) mux2 (
    .sel    (sel_alu_a1),
    .i0     (kara3_o[65:0]),
    .i1     ({2'b0, kara1_o[63:0]}),
    .data_o (alu_a1)
  );

  assign reg3s = shamt ? {62'b0, reg3_o} << 32 : {62'b0, reg3_o};

  mux_4to1 #(.Size(128)) mux3 (
    .sel    (sel_alu_b),
    .i0     ({96'b0, a[31:0]}),
    .i1     ({96'b0, b[31:0]}),
    .i2     (reg3s),
    .i3     ({64'b0, kara2_o[63:0]}),
    .data_o (alu_b)
  );

  assign s = {reg1_o, reg2_o};

endmodule