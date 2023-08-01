module comparator_fp #(
    parameter Size = 64,
    parameter MantSize = Size == 64 ? 52 : 23,
    parameter ExpSize = Size == 64 ? 11 : 8
) (
    input [Size - 1:0] operand_a, operand_b,
    output greater, unordered,
    output reg less, equal
);
    wire mant_eq, mant_less, exp_eq, exp_less;
    wire sign_a, sign_b;
    wire [MantSize - 1:0] mant_a, mant_b;
    wire [ExpSize - 1: 0] exp_a, exp_b;

    assign mant_a = operand_a[MantSize - 1:0];
    assign mant_b = operand_b[MantSize - 1:0];
    assign exp_a = operand_a[Size - 2:MantSize];
    assign exp_b = operand_b[Size - 2:MantSize];
    assign sign_a = operand_a[Size - 1];
    assign sign_b = operand_b[Size - 1];

    assign mant_eq = mant_a == mant_b;
    assign mant_less = mant_a < mant_b;
    assign exp_eq = exp_a == exp_b;
    assign exp_less = exp_a < exp_b;

    assign unordered = ((&exp_a) & (|mant_a)) | ((&exp_b) & (|mant_b));
    assign greater = ~unordered & (~less & ~equal);

    always @* begin
        if (sign_a == sign_b && ~unordered) begin
            if (exp_eq) begin
                if (mant_eq) begin
                    equal = 1'b1;
                    less = sign_a;
                end
                else if (mant_less) begin
                    less = ~sign_a;
                    equal = 1'b0;
                end
                else begin
                    less = sign_a;
                    equal = 1'b0;
                end
            end
            else if (exp_less) begin
                less = ~sign_a;
                equal = 1'b0;
            end
            else begin
                less = sign_a;
                equal = 1'b0;
            end
        end
        else if (sign_a && ~unordered) begin
            less = 1'b1;
            equal = 1'b0;
        end
        else begin
            less = 1'b0;
            equal = 1'b0;
        end
    end

endmodule