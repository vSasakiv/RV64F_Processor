/* Módulo que lida com as operações realizadas no estado "ROUNDING" do somador/subtrator de FP
Arredonda o valor da mantissa e corrige o valor do expoente caso haja um carry, isso com base 
nos modos de arredondamentos definidos por rounding_mode.

rounding_mode
000 - rte - round to nearest, ties to even
001 - rtz - round towards zero
010 - rdn - round down, towards neg inf
011 - rup - round up, towards pos inf
100 - rmm - round to nearest, ties to max
magnitude 
*/

module rounding #(
  parameter Size = 64,
  parameter MantSize = (Size == 64) ? 52 : 23
) (
  input [2:0] rounding_mode, 
  input real_sign,
  input [MantSize + 3:0] mant_normalized,
  output reg carry_rounding, 
  output is_zero,
  output reg [MantSize:0] mant_final
);
  localparam TiesToEven = 3'b000, TowardsZero = 3'b001, TowardNegInf = 3'b010, TowardPosInf = 3'b011, TiesToMax = 3'b100;

  wire is_halfway, carry;
  wire [MantSize:0] mant_rounded_up;
  wire [MantSize + 1:0] mant_truncated;

  //Verifica se os bits de arredondamento são = 0
  assign is_zero = ~(mant_normalized[0] | mant_normalized[1] | mant_normalized[2]); 

  //Verifica se os bits de arredondamento representam metadade do caminho entre os valores acima e abaixo da mantissa
  assign is_halfway = ~(mant_normalized[0] | mant_normalized[1]) & ~is_zero;

  //Obtém mantissa no caso de truncamento dos bits de arredondamento
  assign mant_truncated =  {1'b0, mant_normalized[MantSize + 3:3]};

  //Obtém mantissa no caso em que há arredondamento para cima (adicionando 1)
  cla_adder #(.InputSize(MantSize + 1)) a0 (
    .a(mant_normalized[MantSize + 3:3]),
    .b({{(MantSize){1'b0}}, 1'b1}),
    .sub(1'b0),
    .c_o(carry),
    .s(mant_rounded_up)
  );


  always @* begin
    case (rounding_mode)
      TowardsZero: begin
        {carry_rounding, mant_final} = mant_truncated;
      end
      TowardNegInf: begin
        if (is_zero || real_sign == 0) {carry_rounding, mant_final} = mant_truncated;
        else {carry_rounding, mant_final} = {carry, mant_rounded_up};
      end
      TowardPosInf: begin
        if (is_zero || real_sign == 1) {carry_rounding, mant_final} = mant_truncated;
        else {carry_rounding, mant_final} = {carry, mant_rounded_up};
      end
      TiesToMax: begin
        if (is_halfway) begin
          if (real_sign) {carry_rounding, mant_final} = mant_truncated;
          else {carry_rounding, mant_final} = {carry, mant_rounded_up};
        end else if (mant_normalized[2] == 1'b1) {carry_rounding, mant_final} = {carry, mant_rounded_up};
        else {carry_rounding, mant_final} = mant_truncated;
      end
      default: begin //default: round to nearest, ties to even
        if (is_halfway) begin
            if (mant_normalized[3] == 1) {carry_rounding, mant_final} = {carry, mant_rounded_up};
            else {carry_rounding, mant_final} = mant_truncated;
        end else if (mant_normalized[2] == 1) {carry_rounding, mant_final} = {carry, mant_rounded_up};
        else {carry_rounding, mant_final} = mant_truncated;    
      end
    endcase
  end

endmodule