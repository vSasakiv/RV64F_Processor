module encoder #(
  parameter InputSize = 16,
  parameter OutputSize = $clog2(InputSize)
)(
  input      [InputSize-1:0] data_i,
  output wor [OutputSize-1:0] data_o
);

  genvar i, j;

  generate
    for (i = 0; i < InputSize; i = i + 1)
      begin: loop_i
        for (j = 0; j < OutputSize; j = j + 1)
        begin: loop_j
        if (i[j])
          assign data_o[j] = data_i[i];
        end 
    end
  endgenerate

endmodule