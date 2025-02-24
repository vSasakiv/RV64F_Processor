`timescale 1ns / 100ps
/* Testbench para o módulo que gera o sinal alu_sel_a.
Para cada valor que code pode assumir, verifica se o sinal recebido do módulo é igual ao esperado.
Se algum valor for diferente do esperado ("xpect"), mostra os valores na saída e aumenta a contagem do erros.
Ao final, mostra a quantidade total de erros obtidos */
module alu_sel_a_tb ();
reg [9:0] code;
reg correctASel;
reg [31:0] insn;
wire alu_sel_a;
integer errors;

// task que verifica se a saída do módulo é igual ao valor esperado
task Check;
    input xpectASel;
    if (alu_sel_a !== xpectASel) begin 
        $display ("Error code: %10b, expected %b, got rd: %b", code, xpectASel, alu_sel_a);
        errors = errors + 1;
    end
endtask

// módulo testado
alu_sel_a UUT (.code(code), .alu_sel_a(alu_sel_a), .insn(insn));

// Atribui todos os valores que code pode assumir, especifica o resultado correto em correctAsel e verifica se o módulo funciona para esse valor.
initial begin
    errors = 0;
    insn = 32'b0;
    
    // J
    correctASel = 1;
    code = 10'b0000000001;
    #10
    Check (correctASel);

    // I JARL
    correctASel = 0;
    code = 10'b0000000010;
    #10
    Check (correctASel);

    //  U LUI
    correctASel = 1'b0;
    code = 10'b0000000100;
    #10
    Check (correctASel);

    //  U AUIPC
    correctASel = 1;
    code = 10'b0000001000;
    #10
    Check (correctASel);

    //  B
    correctASel = 0;
    code = 10'b0000010000;
    #10
    Check (correctASel);

    //  R
    correctASel = 0;
    code = 10'b0000100000;
    #10
    Check (correctASel);

    //  S
    correctASel = 0;
    code = 10'b0001000000;
    #10
    Check (correctASel);

    //  I ALU
    correctASel = 0;
    code = 10'b0010000000;
    #10
    Check (correctASel);

    //  I LOAD
    correctASel = 0;
    code = 10'b0100000000;
    #10
    Check (correctASel);

    //  I CSR - ebreak
    insn = 32'h00100073;
    correctASel = 1'b1;
    code = 10'b1000000000;

    #10
    Check (correctASel);

    //  I CSR - ecall
    insn = 32'h00000073;
    correctASel = 1'b0;
    code = 10'b1000000000;

    #10
    Check (correctASel);


    $display ("Finished, got %2d errors", errors);
    $finish;
end
endmodule