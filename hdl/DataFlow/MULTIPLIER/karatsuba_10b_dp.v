module karatsuba_10b_dp (
  input clk,
  input load_reg1, load_reg2, load_reg3, load_reg4,
  input sel_reg1, sel_reg2, sel_reg3, sel_reg4,
  input [1:0] sel_alu_a, sel_alu_b, shamt,
  input sel_alu_b2,
  input sel_mult_a, sel_mult_a2, sel_mult_b, sel_mult_b1,
  input sub,
  input [9:0] a, b,
  output [19:0] s
);
  wire [11:0] reg1_i, reg4_i;
  wire [19:0] reg2_i, reg3_i;
  wire [11:0] reg1_o, reg4_o;
  wire [19:0] reg2_o, reg3_o;

  register #(.Size(12)) reg1 (
    .clk    (clk),
    .data_i (reg1_i),
    .data_o (reg1_o),
    .load   (load_reg1)
  );

  mux_2to1 #(.Size(12)) mux1 (
    .sel    (sel_reg1),
    .i0     ({2'b0, a}),
    .i1     (mult_o),
    .data_o (reg1_i)
  );

  register #(.Size(20)) reg2 (
    .clk    (clk),
    .data_i (reg2_i),
    .data_o (reg2_o),
    .load   (load_reg2)
  );

  mux_2to1 #(.Size(20)) mux2 (
    .sel    (sel_reg2),
    .i0     ({10'b0, b}),
    .i1     (adder_o),
    .data_o (reg2_i)
  );

  register #(.Size(20)) reg3 (
    .clk    (clk),
    .data_i (reg3_i),
    .data_o (reg3_o),
    .load   (load_reg3)
  );

  mux_2to1 #(.Size(20)) mux3 (
    .sel    (sel_reg3),
    .i0     ({8'b0, mult_o}),
    .i1     (adder_o),
    .data_o (reg3_i)
  );

  register #(.Size(12)) reg4 (
    .clk    (clk),
    .data_i (reg4_i),
    .data_o (reg4_o),
    .load   (load_reg4)
  );

  mux_2to1 #(.Size(12)) mux4 (
    .sel    (sel_reg4),
    .i0     (mult_o),
    .i1     (adder_o[11:0]),
    .data_o (reg4_i)
  );

  wire [19:0] alu_a, alu_b, reg3s;
  wire [19:0] adder_o;

  cla_adder #(.InputSize(20)) add0 (
    .a   (alu_a),
    .b   (alu_b),
    .c_o (),
    .sub (sub),
    .s   (adder_o)
  );

  assign reg3s =  (shamt == 2'b00) ? reg3_o :
                  (shamt == 2'b01) ? reg3_o << 5 : reg3_o << 10;

  mux_4to1 #(.Size(20)) mux5 (
    .sel    (sel_alu_a),
    .i0     ({15'b0, reg1_o[9:5]}),
    .i1     ({15'b0, reg2_o[9:5]}),
    .i2     (reg3s),
    .i3     ({8'b0, reg4_o}),
    .data_o (alu_a)
  );

  wire [19:0] alu_b2;

  mux_4to1 #(.Size(20)) mux6 (
    .sel    (sel_alu_b),
    .i0     ({15'b0, reg1_o[4:0]}),
    .i1     ({15'b0, reg2_o[4:0]}),
    .i2     (reg3s),
    .i3     (alu_b2),
    .data_o (alu_b)
  );

  mux_2to1 #(.Size(20)) mux7 (
    .sel    (sel_alu_b2),
    .i0     ({8'b0, reg1_o}),
    .i1     (reg2_o),
    .data_o (alu_b2)
  );

  wire [11:0] mult_o, addr;
  wire [5:0] mult_a, mult_b, mult_a1, mult_b1;

  mux_2to1 #(.Size(6)) mux8 (
    .sel    (sel_mult_a),
    .i0     ({1'b0, reg1_o[4:0]}),
    .i1     (mult_a1),
    .data_o (addr[11:6])
  );
  mux_2to1 #(.Size(6)) mux9 (
    .sel    (sel_mult_a2),
    .i0     ({1'b0, reg1_o[9:5]}),
    .i1     (reg4_o[5:0]),
    .data_o (mult_a1)
  );
  mux_2to1 #(.Size(6)) mux10 (
    .sel    (sel_mult_b),
    .i0     ({1'b0, reg2_o[4:0]}),
    .i1     (mult_b1),
    .data_o (addr[5:0])
  );
  mux_2to1 #(.Size(6)) mux11 (
    .sel    (sel_mult_b1),
    .i0     ({1'b0, reg2_o[9:5]}),
    .i1     (reg2_o[5:0]),
    .data_o (mult_b1)
  );

  mult_lut #(.Size(12)) mult0 (
    .addr(addr),
    .data_o(mult_o)
  );

  assign s = reg3_o;

endmodule