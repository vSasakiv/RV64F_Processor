// módulo registrador parametrizável quanto ao número de bits, com sinal de load síncrono e reset asíncrono
module reg_async_reset #(
	parameter Size = 1
) (
	input clk,
	input [Size-1:0] data_i,
	input load,
	input reset,
	output reg [Size-1:0] data_o
);
	/*Faz reset na borda de subida do sinal "reset".
	Somente faz load na borda de subida do clk, se load = 1 */
	always @(posedge clk or posedge reset) begin
		if (reset)     data_o <= 1'b0; 
		else if (load) data_o <= data_i;
	end	

endmodule