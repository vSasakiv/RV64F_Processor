/* FSM para somador/subtrator de FP
Envia sinais de load e seletores para controlar as operações do circuito */
module add_sub_fsm (
  input start, clk,
  output reg [1:0] sel_a_exp_operand, sel_b_exp_operand, sel_exp_operation,
  output reg sel_a_operand, sel_b_operand, sel_operation,
  output reg load_mant_a, load_mant_b, load_mant_shifted, load_mant_normalized,
  output reg load_effective_expoent, load_expoent_result, load_exp_normalized,
  output reg load_carry, load_real_operation, load_real_sign, load_underflow,
  output reg load_leading_zeros, load_result,
  output reg done
);
  localparam IDLE = 3'b000;
  localparam PRE_NORMALIZING = 3'b001;
  localparam OPERATION = 3'b010;
  localparam NORMALIZING = 3'b011;
  localparam SHIFTING_EXPOENT = 3'b100;
  localparam ROUNDING = 3'b101;
  localparam RESULT = 3'b110;

  reg [2:0] state, next;

  always @(posedge clk) begin
      state <= next; // atualiza o estado a cada ciclo de clock 
  end

  always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? PRE_NORMALIZING : IDLE; 
        PRE_NORMALIZING: next = OPERATION;
        OPERATION: next = NORMALIZING;
        NORMALIZING: next = SHIFTING_EXPOENT;
        SHIFTING_EXPOENT: next = ROUNDING;
        ROUNDING: next = RESULT;
        RESULT: next = IDLE;
        default: next = IDLE;
    endcase
  end

  always @(state) begin
    done = 1'b0;
        sel_a_exp_operand = 2'b00;
        sel_a_operand = 1'b0;
        sel_b_exp_operand = 2'b00;
        sel_b_operand = 1'b0;
        load_mant_a = 1'b0;
        load_mant_b = 1'b0;
        load_effective_expoent = 1'b0;
        load_carry = 1'b0;
        load_leading_zeros = 1'b0;
        load_mant_shifted = 1'b0;
        load_real_operation = 1'b0;
        load_real_sign = 1'b0;
        load_expoent_result = 1'b0;
        load_mant_normalized = 1'b0;
        load_exp_normalized = 1'b0;
        load_underflow = 1'b0;
        load_result = 1'b0;
    case (state)
      PRE_NORMALIZING: begin
        sel_a_exp_operand = 2'b00;
        sel_a_operand = 1'b0;
        sel_b_exp_operand = 2'b00;
        sel_b_operand = 1'b0;
        sel_exp_operation = 2'b00;
        sel_operation = 1'b0;
        load_mant_a = 1'b1;
        load_mant_b = 1'b1;
        load_effective_expoent = 1'b1;
      end
      OPERATION: begin
        sel_a_exp_operand = 2'b00;
        sel_a_operand = 1'b1;
        sel_b_exp_operand = 2'b00;
        sel_b_operand = 1'b1;
        sel_exp_operation = 2'b00;
        sel_operation = 1'b1;
        load_carry = 1'b1;
        load_leading_zeros = 1'b1;
        load_mant_shifted = 1'b1;
        load_real_operation = 1'b1;
        load_real_sign = 1'b1;
      end
      NORMALIZING: begin
        sel_a_exp_operand = 2'b01;
        sel_a_operand = 1'b0;
        sel_b_exp_operand = 2'b01;
        sel_b_operand = 1'b0;
        sel_exp_operation = 2'b01;
        sel_operation = 1'b0;
        load_expoent_result = 1'b1;
        load_mant_normalized = 1'b1;
      end
      SHIFTING_EXPOENT: begin
        sel_a_exp_operand = 2'b10;
        sel_a_operand = 1'b0;
        sel_b_exp_operand = 2'b10;
        sel_b_operand = 1'b0;
        sel_exp_operation = 2'b10;
        sel_operation = 1'b0;
        load_exp_normalized = 1'b1;
        load_underflow = 1'b1;
      end
      ROUNDING: begin
        sel_a_exp_operand = 2'b11;
        sel_a_operand = 1'b0;
        sel_b_exp_operand = 2'b11;
        sel_b_operand = 1'b0;
        sel_exp_operation = 2'b11;
        sel_operation = 1'b0;
        load_result = 1'b1;
      end
      RESULT: begin
        done = 1'b1;
      end
      default: begin 
        done = 1'b0;
        sel_a_exp_operand = 2'b00;
        sel_a_operand = 1'b0;
        sel_b_exp_operand = 2'b00;
        sel_b_operand = 1'b0;
        sel_exp_operation = 2'b00;
        sel_operation = 1'b0;
        load_mant_a = 1'b0;
        load_mant_b = 1'b0;
        load_effective_expoent = 1'b0;
        load_carry = 1'b0;
        load_leading_zeros = 1'b0;
        load_mant_shifted = 1'b0;
        load_real_operation = 1'b0;
        load_real_sign = 1'b0;
        load_expoent_result = 1'b0;
        load_mant_normalized = 1'b0;
        load_exp_normalized = 1'b0;
        load_underflow = 1'b0;
        load_result = 1'b0;
      end
    endcase
  end

endmodule