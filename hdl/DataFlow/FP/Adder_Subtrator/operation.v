/*Módulo que lida com as operações realizadas no estado "OPERATION" do somador/subtrator de FP */
module operation #(
    parameter Size = 32
) (
  input [Size - 1:0] operand_a, operand_b,
  input sub, sign_a, sign_b, carry,
  input [MantSize + 3:0] data_o, data_o_c,
  output [$clog2(MantSize + 4) - 1:0] leading_zeros,
  output [MantSize + 3:0] mant_shifted,
  output real_sign, real_operation
);
localparam ExpSize = (Size == 64) ? 11 : 8;
localparam MantSize = (Size == 64) ? 52 : 23; 

wire [MantSize + 3:0] mant_result;

  //Obtém a operação real, com base nos sinais 
  assign real_operation = sub ^ sign_a ^ sign_b;

  //Obtém o sinal do resultado final
  assign real_sign = (~operand_a[Size - 1] & real_operation & ~carry) || (~real_operation & operand_a[Size - 1]) || (carry & operand_a[Size - 1]);

  //Seleciona o resultado complementado se a operação for uma subtração e não houver carry, o normal caso contrário
  mux_2to1 #(.Size(MantSize + 4)) m2 (
    .i0(data_o),
    .i1(data_o_c),
    .sel(real_operation & (!carry)),
    .data_o(mant_result)
  );

  //Se for uma soma, shifta o resultado pelo valor do carry
  assign mant_shifted = (~real_operation) ? {carry, mant_result} >> carry : mant_result;

  //Calcula a quantidade de leading zeros na mantissa shiftada
  leading_zero_counter #(.SizeMantissa(MantSize + 1)) ldc (
    .mantissa(mant_shifted),
    .leading_zeros(leading_zeros)
  );

endmodule