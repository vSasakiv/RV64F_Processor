module register #(
    parameter Size = 1
) (
    input clk,
    input [Size - 1:0] data_i,
    input load,
    output reg [Size - 1:0] data_o
);

    always @(posedge clk) begin
      if (load) data_o <= data_i;
    end

endmodule