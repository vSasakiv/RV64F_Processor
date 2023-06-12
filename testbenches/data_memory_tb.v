`timescale 1 ns / 100 ps

module data_memory_tb ();
  reg clk;
  reg write;
  reg [1:0] sel_mem_size;
  reg [63:0] data_i;
  reg [63:0] addr;
  reg [63:0] correct_data_o;
  wire [63:0] data_o;
  integer errors, i;

  initial
    clk = 0; // Clock inicial estabelecido como 0;

  always 
    #1 clk = ~clk;

  data_memory UUT (
    .clk,
    .write,
    .sel_mem_size,
    .data_i,
    .addr,
    .data_o
  );

  // Task responsável por checar se a saída do módulo é igual ao valor esperado
  task check;
    input [63:0] expected_data_o;
    if (data_o !== expected_data_o) begin 
      $display ("Error, data_o: %h, expeted: %h", data_o, expected_data_o);
      errors = errors + 1;
    end 
  endtask

  initial begin
    errors = 0;
    sel_mem_size = 2'b11;
    for (i = 0; i < 1000; i++) begin
      data_i = $urandom; // ***Alterar a quantidade de bits para corresponder ao Size ***
      addr = $urandom & (8'b11111111 - 3'd7);
      write = 1;
            
      #2 
      correct_data_o = data_i; 
      check (correct_data_o); // Verifica se a saída é igual a entrada se write = 1

      write = 0;
      correct_data_o = data_i;
      data_i = $urandom; 
            
      #2
      check (correct_data_o); // Verifica se a  saída permanece igual a anterior caso write = 0
    end

    $display ("Finished, got %2d errors", errors);
    $finish;
  end

endmodule