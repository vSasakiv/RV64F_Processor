`timescale 1 ns / 100 ps
/*
Testbench para a fsm que controla as operações de load e store
*/
module fsm_branch_jump_tb ();

reg [31:0] ins, code;
reg clk, start, lu, ls, eq;
wire [2:0] func3;
wire [1:0] sel_rd;
wire load_pc, load_regfile, load_rs1, load_rs2, load_alu, load_data_memory, write_mem;
wire load_imm, load_flags, load_pc_alu;
wire sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b, sub_sra;

fsm_branch_jump UUT (
    ins,
    code, 
    start, 
    clk, 
    lu, 
    ls, 
    eq, 
    func3, 
    sel_rd, 
    load_pc, 
    load_regfile, 
    load_rs1, 
    load_rs2, 
    load_alu,
    load_imm,
    load_flags,
    load_pc_alu,
    sel_pc_next, 
    sel_pc_alu, 
    sel_alu_a, 
    sel_alu_b, 
    sub_sra,
    load_data_memory,
    write_mem
    );

initial
    clk = 1; // Clock inicial estabelecido como 1;

always 
    #1 clk = ~clk;

initial begin
    $dumpfile("fsm.vcd"); 
    $dumpvars(20, fsm_branch_jump_tb);
end
initial begin
    // executamos uma simulação, dando os sinais que ela receberia numa operação real
    // em seguida é analisado o waveform gerado para verificar se o funcionamento é aceitável
    start = 1'b1;
    ins = 32'b00000001010000000000101001101111; // jal x20, 20
    code = {4'b0, 1'b1, 27'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000001111000010000010101100111; // jalr x10, x2, 30
    code = {6'b0, 1'b1, 25'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000000101000101000101001100011; // beq x5, x10, 20
    eq = 1;
    code = {7'b0, 1'b1, 24'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000000101000101101001001100011; // bge x5, x10, 5
    ls = 1;
    code = {7'b0, 1'b1, 24'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000000101000101111001001100011; // bgeu x5, x10, 4
    lu = 0;
    code = {7'b0, 1'b1, 24'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000000101000101100001001100011; // blt x5, x10, 4
    ls = 1;
    code = {7'b0, 1'b1, 24'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000000101000101110001001100011; // bltu x5, x10, 4
    lu = 1;
    code = {7'b0, 1'b1, 24'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000000101000101001001001100011; // bne x5, x10, 4
    eq = 1;
    code = {7'b0, 1'b1, 24'b0};
    #5
    start = 1'b0;
    #20
    $stop;
end

endmodule