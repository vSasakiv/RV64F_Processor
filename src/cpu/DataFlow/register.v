// módulo registrador parametrizável quanto ao número de bits, com sinal de load síncrono e sem reset
module register #(
    parameter Size = 1 // parâmetro que indica o número de bits do registrador
) (
    input clk, // sinal de clock
    input [Size - 1:0] data_i, // entrada do registrador
    input load, // sinal de load síncrono
    output reg [Size - 1:0] data_o // saída do registrador
);

    always @(posedge clk) begin
      if (load) data_o <= data_i; // a toda borda de clock, caso o load esteja ativado, carregamos a entrada no registrador.
    end

endmodule