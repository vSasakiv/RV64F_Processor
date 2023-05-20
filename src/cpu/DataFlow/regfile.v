//Conjunto de registradors de n bits, sendo "n" decidido pelo parâmetro Size
module regfile #(
  parameter Size = 64
) (
  input clk, // sinal de clock
  input load, // sinal de load
  input [4:0] rd_addr, // endereço do registrador destino (a ser gravado)
  input [4:0] rs1_addr, // endereço da saída 1
  input [4:0] rs2_addr, // endereço da saída 2
  input [Size - 1:0] rd_i, // valor de entrada ao registrador destino
  output [Size - 1:0] rs1_o, // valor de saída 1
  output [Size - 1:0] rs2_o // valor de saída 2
);
  wire [Size - 1:0] rs[31:0]; // Array de 32 vetores (wires de Size bits) que conecta as saídas dos registradores aos muxes
  wire [31:0] dec_o; //Saída do decoder
	wire [31:0] load_reg; //Wire que guarda valores de load para cada registrador. Somente 1bit vale 1 (load = 1).
    
  assign rs[0] = {Size{1'b0}}; // Força registrador 0 a ser sempre 0
  assign load_reg = dec_o & {32{load}};

  //Muxes que selecionam as sáidas a partir de um endereço dado
  assign rs1_o = rs[rs1_addr];
  assign rs2_o = rs[rs2_addr];

  //Responsável por obter load_reg a partir do valor de rd_addr
  decoder #(5) dec5to32 (.data_i(rd_addr), .data_o(dec_o));
	 
  //Instancia 31 registradores (não e necessário instanciar o registrador 0)
  genvar i;
  generate
    for (i = 1; i < 32; i = i + 1) begin : registers
      register #(.Size(Size)) ri (
        .clk   (clk), 
        .data_i(rd_i), 
        .load  (load_reg[i]), 
        .data_o(rs[i])
      );
	  end
	endgenerate   

endmodule