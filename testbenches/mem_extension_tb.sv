`timescale 1 ns / 100 ps

module mem_extension_tb ();
  logic [2:0] sel_mem_extension; // entrada para definir qual deve ser a extensão a ser realizada
  logic [63:0] mem_value; // entrada do valor de memória
  logic [63:0] correct_mem_extended;
  logic [63:0] mem_extended; // saída do valor de memória estendido e corrigido
  integer errors;

  // Task responsável por checar se a saída do módulo é igual ao valor esperado
  task check;
      input [63:0] expected_mem_extended;
      if (mem_extended !== expected_mem_extended) begin 
          $display ("Error, mem_extended: %h, expected: %h", mem_extended, expected_mem_extended); 
          errors = errors + 1;
      end 
  endtask

  task display_error;
    begin
        errors += 1;
        $display ("--Error--");
        $display ("mem_value: %h, sel_mem_extension: %b", mem_value, sel_mem_extension);
        $display ("got mem_extended: %h", mem_extended);
        $display ("Correct value: %h", correct_mem_extended);
		    $display ("--------");
    end
  endtask

  mem_extension UUT (
    .sel_mem_extension,
    .mem_value,
    .mem_extended
  );

  initial begin
    errors = 0;

    mem_value = {$urandom, $urandom};
    sel_mem_extension = 3'b000; // load byte
    correct_mem_extended = {{56{mem_value[7]}}, mem_value[7:0]};
    #1
    assert (correct_mem_extended == mem_extended) else display_error;

    mem_value = {$urandom, $urandom};
    sel_mem_extension = 3'b100; // load byte unsigned
    correct_mem_extended = {56'b0, mem_value[7:0]};
    #1
    assert (correct_mem_extended == mem_extended) else display_error;

    mem_value = {$urandom, $urandom};
    sel_mem_extension = 3'b001; // load halfword
    correct_mem_extended = {{48{mem_value[15]}}, mem_value[15:0]};
    #1
    assert (correct_mem_extended == mem_extended) else display_error;

    mem_value = {$urandom, $urandom};
    sel_mem_extension = 3'b101; // load halfword unsigned
    correct_mem_extended = {48'b0, mem_value[15:0]};
    #1
    assert (correct_mem_extended == mem_extended) else display_error;

    mem_value = {$urandom, $urandom};
    sel_mem_extension = 3'b010; // load word
    correct_mem_extended = {{32{mem_value[31]}}, mem_value[31:0]};
    #1
    assert (correct_mem_extended == mem_extended) else display_error;

    mem_value = {$urandom, $urandom};
    sel_mem_extension = 3'b110; // load word unsigned
    correct_mem_extended = {32'b0, mem_value[31:0]};
    #1
    assert (correct_mem_extended == mem_extended) else display_error;

    mem_value = {$urandom, $urandom};
    sel_mem_extension = 3'b011; // load doubleword
    correct_mem_extended = mem_value;
    #1
    assert (correct_mem_extended == mem_extended) else display_error;
    
    $display ("Finished, got %2d errors", errors);
    $finish;
  end

endmodule