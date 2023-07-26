module multiplier_fp_fsm (
  input start, clk,
  input done_karat, invalid, zero,
  output reg sel_a_operand, 
  output reg [1:0] sel_b_operand, sel_operation, 
  output reg load_exp_result, load_result, load_underflow, load_inexact, load_overflow,
  output reg done_fsm, start_op
);

localparam IDLE = 3'b000;
localparam S0 = 3'b001;
localparam S1 = 3'b010;
localparam S2 = 3'b011;
localparam S3 = 3'b100;
localparam S4 = 3'b101;
localparam S5 = 3'b111;


  reg [2:0] state, next;

  always @(posedge clk) begin
      state <= next; // atualiza o estado a cada ciclo de clock 
  end

  always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1 && ~invalid) ? ((zero) ? S4: S0) : IDLE; 
        S0: next = S1;
        S1: next = S2; 
        S2: next = (done_karat == 1'b1) ? S3 : S2;
        S3: next = S4;
        S4: next = S5;
        S5: next = IDLE;
        default: next = IDLE;
    endcase
  end

  always @(state) begin
    start_op = 1'b0;
    sel_a_operand = 1'b0;
    sel_b_operand = 2'b00;
    sel_operation = 2'b00;
    load_exp_result = 1'b0;
    load_result = 1'b0;
    done_fsm = 1'b0;
    load_underflow = 1'b0;
    load_inexact = 1'b0;
    load_overflow = 1'b0;
    case (state)
      S0: begin
        start_op = 1'b1;
        sel_a_operand = 1'b0;
        sel_b_operand = 2'b00;
        sel_operation = 2'b00;
        load_exp_result = 1'b1;
      end
      S1: begin
        sel_a_operand = 1'b1;
        sel_b_operand = 2'b01;
        sel_operation = 2'b01;
        load_exp_result = 1'b1;
        load_underflow = 1'b1;
        load_overflow = 1'b1;
      end
      S3: begin
        sel_a_operand = 1'b1;
        sel_b_operand = 2'b10;
        sel_operation = 2'b10;
        load_exp_result = 1'b1;
      end
      S4: begin
        sel_a_operand = 1'b1;
        sel_b_operand = 2'b11;
        sel_operation = 2'b11;
        load_inexact = 1'b1;
        load_result = 1'b1;
      end
      S5: begin
        done_fsm = 1'b1;
      end
      default begin
        start_op = 1'b0;
        sel_a_operand = 1'b0;
        sel_b_operand = 2'b00;
        sel_operation = 2'b00;
        load_exp_result = 1'b0;
        done_fsm = 1'b0;
        load_result = 1'b0;
        load_underflow = 1'b0;
        load_inexact = 1'b0;
        load_overflow = 1'b0;
      end
    endcase 
  end

endmodule