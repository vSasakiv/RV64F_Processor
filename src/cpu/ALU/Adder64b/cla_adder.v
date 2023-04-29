module cla_adder #(
    parameter InputSize = 64
) (
    input [InputSize - 1:0] a, b,
    input sub,
    output c_o,
    output [InputSize - 1:0] s
);

    /* XOR entre cada bit de B e o SUB, responsável por complementar B caso SUB = 1*/
	
    wire carry[0:InputSize - 1];
    wire p[0:InputSize - 1];
    wire g[0:InputSize - 1];
    wire pc[0:InputSize - 1];
	wire [InputSize - 1:0] c;
	 
	assign c = b ^ {64{sub}};
	assign c_o = carry[InputSize - 1];

    and p01 (pc[0], p[0], sub);
    or c01 (carry[0], g[0], pc[0]);

    partial_full_adder1b u0 (.a(a[0]), .b(c[0]), .c_i(sub), .s(s[0]), .p(p[0]), .g(g[0]));
    partial_full_adder1b a1 (.a(a[InputSize - 1]), .b(c[InputSize - 1]), .c_i(carry[InputSize - 2]), .s(s[InputSize - 1]), .p(p[InputSize - 1]), .g(g[InputSize - 1]));

    genvar i;
    generate 
        for (i = 1; i < InputSize; i = i + 1) begin : P_G
            and pi (pc[i], p[i], carry[i - 1]);
            or ci (carry[i], g[i], pc[i]);
        end

        for (i = 1; i < InputSize - 1; i = i + 1) begin : Adders
            partial_full_adder1b a1 (.a(a[i]), .b(c[i]), .c_i(carry[i - 1]), .s(s[i]), .p(p[i]), .g(g[i]));
        end
    
    endgenerate
        
endmodule