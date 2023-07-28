module karatsuba_34b_cu (
  input start, clk, done1, done2, done3,
  output reg start1, start2, start3, shamt,
  output reg load_reg1, load_reg2, load_reg3, sel_alu_a1,
  output reg [1:0] sel_alu_a, sel_alu_b,
  output reg sub, done
);

  localparam IDLE = 3'b000;
  localparam S0 = 3'b001;
  localparam S1 = 3'b010;
  localparam S2 = 3'b011;
  localparam S3 = 3'b100;
  localparam S4 = 3'b101;
  localparam S5 = 3'b110;
  localparam S6 = 3'b111;

  reg [2:0] state, next;

  always @(posedge clk) begin
    state <= next;
  end

  always @* begin
    case (state)
      IDLE: next = start ? S0 : IDLE;
      S0: next = S1;
      S1: next = (done1 == 1'b1 && done2 == 1'b1) ? S2 : S1;
      S2: next = S3;
      S3: next = S4;
      S4: next = S5;
      S5: next = S6;
      S6: next = IDLE;
      default: next = IDLE;
    endcase
  end

  always @(state) begin
    {start1, start2, start3} = 3'b0;
    {load_reg1, load_reg2, load_reg3} = 3'b0;
    {sel_alu_a, sel_alu_a1, sel_alu_b, shamt} = 6'b0;
    sub = 1'b0;
    done = 1'b0;
    case(state)
      S0: begin
        start1 = 1'b1;
        start2 = 1'b1;
        load_reg2 = 1'b1;
      end
      S1: begin
        sel_alu_a = 2'b01;
        sel_alu_b = 2'b01;
        start3 = 1'b1;
      end
      S2: begin
        sel_alu_a = 2'b10;
        sel_alu_a1 = 1'b1;
        shamt = 1'b1;
        sel_alu_b = 2'b11;
        load_reg1 = 1'b1;
        load_reg2 = 1'b1;
      end
      S3: begin
        sel_alu_a = 2'b10;
        sel_alu_a1 = 1'b1;
        sel_alu_b = 2'b11;
        load_reg3 = 1'b1;
      end
      S4: begin
        sel_alu_a = 2'b10;
        sel_alu_b = 2'b10;
        sub = 1'b1;
        load_reg3 = 1'b1;
      end
      S5: begin
        sel_alu_a = 2'b11;
        sel_alu_b = 2'b10;
        shamt = 1'b1;
        load_reg1 = 1'b1;
        load_reg2 = 1'b1;
      end
      S6: begin
        done = 1'b1;
      end
      default: done = 1'b0;

    endcase
  end
endmodule