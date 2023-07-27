`timescale 1 ns / 100 ps
/* Testbench para o módulo responsável por decodificar o imediato de uma instrução. 
Para opcodes e instruções escolhidas aleatoriamente, exibe o imediato obtido através do "$monitor" para verificação. */
module imm_gen_tb ();
logic [63:0] imm; // Imediato gerado
logic [63:0] correct_imm;
logic [31:0] insn; // Instrução
logic [31:0] code; // Array com todos os opcodes de instruções que possuem campo para um imediato
integer errors;

  task check;
    input [63:0] expected_imm;
    if (imm !== expected_imm) begin 
      $display ("Error, got imm: %h, expeted: %h, code %b", imm, expected_imm, code);
      errors = errors + 1;
    end
  endtask

	task display_error;
		begin
			 	errors += 1;
        $display ("--Error--");
        $display ("Insn: %h", insn);
        $display ("got imm: %h ", imm);
        $display ("Correct imm: %h", correct_imm);
				$display ("--------");
		end
	endtask

	//Módulo auxiliar
	opdecoder op_dec (
			.opcode(insn[6:0]),
			.code
	);

  // Módulo testado
  imm_gen UUT (
    .insn, 
    .code,
    .imm
  );

  initial begin
    errors = 0;

    insn = {$urandom, 7'b0110111}; // U - LUI
    correct_imm = {{32{insn[31]}}, insn[31:12], 12'b0};
    #1
		assert (correct_imm == imm) else display_error;

    insn = {$urandom, 7'b0010111}; // U - AUIPC
    correct_imm = {{32{insn[31]}}, insn[31:12], 12'b0};
    #1
		assert (correct_imm == imm) else display_error;

    insn = {$urandom, 7'b1101111}; // J 
    correct_imm = {{44{insn[31]}}, insn[19:12], insn[20], insn[30:21], 1'b0};;
    #1
		assert (correct_imm == imm) else display_error;

    insn = {$urandom, 7'b1100111}; // I - JARL
    correct_imm = {{52{insn[31]}}, insn[31:20]};
    #1
		assert (correct_imm == imm) else display_error;
    
    insn = {$urandom, 7'b0010011}; // I - ALU
    correct_imm = {{52{insn[31]}}, insn[31:20]};
    #1
		assert (correct_imm == imm) else display_error;
    
    insn = {$urandom, 7'b0000011}; // I - LOAD
    correct_imm = {{52{insn[31]}}, insn[31:20]};
    #1
		assert (correct_imm == imm) else display_error;
    
    insn = {$urandom, 7'b1100011}; // B
    correct_imm = {{52{insn[31]}}, insn[7], insn[30:25], insn[11:8], 1'b0};
    #1
		assert (correct_imm == imm) else display_error;
    
    insn = {$urandom, 7'b0100011}; // S
    correct_imm = {{52{insn[31]}}, insn[31:25], insn[11:7]};
    #1
		assert (correct_imm == imm) else display_error;
    
    insn = {$urandom, 7'b1110011}; // CSR
    correct_imm = {{52{insn[31]}}, insn[31:20]};
    #1
		assert (correct_imm == imm) else display_error;
    
    $display("Finished, got %d errors", errors);
    $finish;
    end
    
endmodule