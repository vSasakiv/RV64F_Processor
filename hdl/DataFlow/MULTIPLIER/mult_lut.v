module mult_lut #(
  parameter Size = 12
) (
  input [Size-1:0] addr,
  output [Size-1:0] data_o
);
  reg [11:0] memory [0:(1 << Size) - 1];
  assign data_o = memory[addr];

  initial begin: populate
    integer i, j;
    for (i = 0; i < 2 << (Size/2); i = i+1) begin
      for (j = 0; j < 2 << (Size/2); j = j+1) begin
        memory[{i[(Size/2)-1:0], j[(Size/2)-1:0]}] = i[(Size/2)-1:0] * j[(Size/2)-1:0];
      end
    end
  end
endmodule