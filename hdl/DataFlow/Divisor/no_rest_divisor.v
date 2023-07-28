
module no_rest_divisor #(
    parameter Size=64
) (
    input clk, start,
    input [Size - 1:0] divisor, dividend,
    output reg done,
    output [Size - 1:0] quotient, remainder
);

localparam IDLE = 2'b00;
localparam EXEC = 2'b01;

reg [Size*2 :0] Aux_quotient;
reg [Size*2 :0] Aux;
reg [$clog2(Size) : 0] n_dividend;
reg [Size - 1: 0] divisor_reg;
reg [1:0] state, next;

assign quotient = Aux_quotient[Size - 1: 0];
assign remainder = Aux_quotient[2*Size - 1: Size];

always @* begin
    case (state)
        IDLE: next = start ? EXEC : IDLE;
        EXEC: next = done ? IDLE : EXEC;
        default: next = IDLE;
    endcase
end

always @(posedge clk) begin
    state <= next;
end

always @(posedge clk) begin
    case (state) 
        IDLE: begin
            divisor_reg <= divisor;
            Aux_quotient[Size - 1: 0] <= dividend;
            Aux_quotient[2*Size : Size] <= {(Size + 1){1'b0}};
            n_dividend <= {1'b1, {$clog2(Size){1'b0}}};
            done <= 1'b0;
        end
        EXEC: begin
            if (n_dividend != 0) begin
                if (Aux_quotient[2*Size]) Aux = (Aux_quotient << 1) + ({1'b0, divisor_reg, {Size{1'b0}}});
                else Aux = (Aux_quotient << 1) - ({1'b0, divisor_reg, {Size{1'b0}}});
                if (Aux[2*Size]) Aux[0] = 1'b0;
                else Aux[0] = 1'b1;
                Aux_quotient <= Aux;
                n_dividend <= n_dividend - 1;
            end
            else begin
                if (Aux_quotient[2*Size]) Aux = Aux_quotient + ({1'b0, divisor_reg, {Size{1'b0}}});
                else Aux = Aux_quotient;
                Aux_quotient <= Aux;
                done <= 1'b1;
            end
        end
        default: done <= 1'b0;
    endcase 
end

endmodule