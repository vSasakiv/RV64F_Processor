module sqrt_fp_fsm (
  input start, clk, done_sqrt,
  output reg reset, done, load_result, load_invalid, load_inexact
);
  localparam IDLE = 3'b000;
  localparam OPERATION = 3'b010;
  localparam LOAD_VALUES = 3'b011;
  localparam RESULT = 3'b110;

	reg [2:0] state, next;

  always @(posedge clk) begin
      state <= next; // atualiza o estado a cada ciclo de clock 
  end

	always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? OPERATION : IDLE; 
        OPERATION: next = (done_sqrt == 1'b1) ? LOAD_VALUES : OPERATION;
		LOAD_VALUES: next =RESULT;
        RESULT: next = IDLE;
        default: next = IDLE;
    endcase
  end

	always @(state) begin
    	done = 1'b0;
		reset = 1'b1;
		load_result = 1'b0;
		load_invalid = 1'b0;
		load_inexact = 1'b0;
		case (state)
			IDLE: begin
				done = 1'b0;
				reset = 1'b1;
			end
			OPERATION: begin
				done = 1'b0;
				reset = 1'b0;
			end
			LOAD_VALUES: begin
				reset = 1'b0;
				load_result = 1'b1;
				load_invalid = 1'b1;
				load_inexact = 1'b1;
			end
			RESULT: begin 
				done = 1'b1;
				reset = 1'b0;
			end
			default	: begin
				done = 1'b0;
				reset = 1'b1;
				load_result = 1'b0;
				load_invalid = 1'b0;
				load_inexact = 1'b0;
			end
		endcase
	end



endmodule

