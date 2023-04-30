/* Testebench para o módulo RegFile, um conjunto de registradors de n bits, sendo "n" decidido pelo parâmetro Size.
Verifica, para 16 pares de registradores, se a cada borda positiva  de clk no módulo:
1 - O valor aleatório rd_i é guardado no registrador de endereço rd_addr, com load = 1;
2 - Os valores de saída desses registradores, rs1_o e rs2_o, são iguais ao esperado;
3 - A saída permanece igual a anterior caso load = 0. */
`timescale 1 ns / 100 ps

module regfile_tb ();
  parameter Size = 64; // Parâmetro que define o tamanho do registrador (quantidade de bits guardados)
  reg clk; 
  reg load;
  reg [Size - 1:0] correct_rs1, correct_rs2; 
  reg [Size - 1:0] rd_i; // entrada do registrador destino
  reg [4:0] rs1_addr; // seletor de registrador 1
  reg [4:0] rs2_addr; // seletor de registrador 2
  reg [4:0] rd_addr; // seletor do registrador destino
  wire [Size - 1:0] rs1_o; // saída 1 do registrador
  wire [Size - 1:0] rs2_o; // saída 2 do registrador
  integer errors, i;

  initial
    clk = 1; // Clock inicial estabelecido como 1;

  always 
    #1 clk = ~clk;

  //Módulo testado 
  regfile #(Size) UUT (
    .clk, 
    .load, 
    .rd_addr, 
    .rs1_addr, 
    .rs2_addr,
    .rd_i,
    .rs1_o,
    .rs2_o
  );

  // Task responsável por checar se a saída do módulo é igual ao valor esperado
  task check;
    input [Size - 1:0] expected_rs1, expected_rs2;
    begin
      if (expected_rs1 !== rs1_o) begin 
        $display ("Error, rs1_o: %h, expeted: %h", rs1_o, expected_rs1);  
          errors = errors + 1;
      end 
      if (expected_rs2 !== rs2_o) begin 
        $display ("Error, rs2_o: %h, expeted: %h", rs2_o, expected_rs2); 
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;

    //Para 16 pares de registradores (i e 31-i), verifica os valores estão sendo carregados e mantidos nos registrados
    for (i = 0; i < 32; i++) begin

      //Carrega um valor aleatorio no endereço i
      rd_i = $urandom & {Size*(1'b1)};
      rd_addr = i;
      load = 1;
      #3
      correct_rs1 = (i == 0? 64'b0 : rd_i); // atribui o valor correto que se esperará no rs1

      //Carrega um valor aleatorio no endereço (31-i)
      rd_i = $urandom & {Size*(1'b1)};; 
      rd_addr = (31-i);
      load = 1;
      #3
      correct_rs2 = (31 - i == 0? 64'b0 : rd_i); // atribui o valor correto que se esperará no rs2

      //Com load = 0, verifica se a as saídas rs1 e rs2 estão corretas,
      //(nos endereços em que os valores foram carregados)  
      load = 0;
      rs1_addr = i;
      rs2_addr = (31 - i);
      #2
      check (correct_rs1, correct_rs2);

      //Tentativa carregar novos valores nos endereços de rs1 e rs2, com load = 0
      rd_i = $urandom & {Size*(1'b1)};; 
      rd_addr = i;
      #3
      rd_i = $urandom & {Size*(1'b1)};; 
      rd_addr = (31-i);
      #3

      //Verifica se os valores de rs1 e rs2 foram alterados com load sendo 0
      check (correct_rs1, correct_rs2);
    end

    $display ("Finished, got %2d errors", errors);
    $finish;
    
    end

endmodule  