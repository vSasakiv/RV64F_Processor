module karatsuba_34b_dp (
  input clk, start1, start2, start3, shamt, sub,
  input load_reg1, load_reg2, load_reg3, sel_alu_a1,
  input [1:0] sel_alu_a, sel_alu_b,
  input [33:0] a, b,
  output done1, done2, done3,
  output [67:0] s
);

  wire [35:0] kara1_o, kara2_o, kara3_o;

  karatsuba_18b kara1 (
    .clk   (clk),
    .start (start1),
    .a     ({1'b0, a[33:17]}),
    .b     ({1'b0, b[33:17]}),
    .s     (kara1_o),
    .done  (done1)
  );

  karatsuba_18b kara2 (
    .clk   (clk),
    .start (start2),
    .a     ({1'b0, a[16:0]}),
    .b     ({1'b0, b[16:0]}),
    .s     (kara2_o),
    .done  (done2)
  );

  karatsuba_18b kara3 (
    .clk   (clk),
    .start (start3),
    .a     (reg2_o[17:0]),
    .b     (adder_o[17:0]),
    .s     (kara3_o),
    .done  (done3)
  );

  wire [33:0] reg1_o, reg2_o;
  wire [35:0] reg3_o;

  register #(.Size(34)) rout1 (
    .clk    (clk),
    .data_i (adder_o[67:34]),
    .data_o (reg1_o),
    .load   (load_reg1)
  );

  register #(.Size(34)) rout2(
    .clk    (clk),
    .data_i (adder_o[33:0]),
    .data_o (reg2_o),
    .load   (load_reg2)
  );

  register #(.Size(36)) rout (
    .clk    (clk),
    .data_i (adder_o[35:0]),
    .data_o (reg3_o),
    .load   (load_reg3)
  );

  wire [67:0] alu_a, alu_b, adder_o;

  cla_adder #(.InputSize(68)) add0 (
    .a   (alu_a),
    .b   (alu_b),
    .c_o (),
    .sub (sub),
    .s   (adder_o)
  );

  wire [35:0] alu_a1;

  mux_4to1 #(.Size(68)) mux1 (
    .sel    (sel_alu_a),
    .i0     ({51'b0, a[33:17]}),
    .i1     ({51'b0, b[33:17]}),
    .i2     (alu_a1s),
    .i3     ({reg1_o, reg2_o}),
    .data_o (alu_a)
  );

  wire [67:0] alu_a1s;
  assign alu_a1s = shamt ? {32'b0, alu_a1} << 34 : {32'b0, alu_a1};

  mux_2to1 #(.Size(36)) mux2 (
    .sel    (sel_alu_a1),
    .i0     (kara3_o),
    .i1     ({2'b0, kara1_o[33:0]}),
    .data_o (alu_a1)
  );

  wire [67:0] reg3s;
  assign reg3s = shamt ? {32'b0, reg3_o} << 17 : {32'b0, reg3_o};

  mux_4to1 #(.Size(68)) mux3 (
    .sel    (sel_alu_b),
    .i0     ({51'b0, a[16:0]}),
    .i1     ({51'b0, b[16:0]}),
    .i2     (reg3s),
    .i3     ({34'b0, kara2_o[33:0]}),
    .data_o (alu_b)
  );

  assign s = {reg1_o, reg2_o};

endmodule