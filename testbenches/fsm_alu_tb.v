`timescale 1 ns / 100 ps
/*
Testbench para a fsm que controla as operações da alu
*/
module fsm_alu_tb ();

reg [31:0] insn, code;
reg clk, start, lu, ls, eq;
wire [2:0] func3;
wire [1:0] sel_rd;
wire load_pc, load_ins, load_regfile, load_rs1, load_rs2, load_alu, load_data_memory;
wire load_imm, load_flags, load_pc_alu;
wire sel_pc_next, sel_alu_a, sel_alu_b, sub_sra;
wire sel_pc_increment, sel_pc_jump, sel_mem_next, memory_start, sel_mem_operation;

fsm_alu UUT (
    .insn,
    .code, 
    .start, 
    .clk, 
    .lu, 
    .ls, 
    .eq,
    .sel_rd, 
    .load_pc,
    .load_regfile, 
    .load_rs1, 
    .load_rs2, 
    .load_alu,
    .load_imm,
    .load_flags,
    .load_pc_alu, 
    .sel_pc_next, 
    .sel_alu_a, 
    .sel_alu_b, 
    .sub_sra,
    .load_data_memory,
    .sel_pc_increment,
    .sel_pc_jump,
    .sel_mem_next,
    .memory_start,
    .sel_mem_operation
    );

initial
    clk = 1; // Clock inicial estabelecido como 1;

always 
    #1 clk = ~clk;

initial begin
    $dumpfile("fsm.vcd"); 
    $dumpvars(20, fsm_alu_tb);
end
initial begin
    // executamos uma simulação, dando os sinais que ela receberia numa operação real
    // em seguida é analisado o waveform gerado para verificar se o funcionamento é aceitável
    start = 1'b1;
    insn = 32'b00000000000100010000001010110011; // add x5, x2, x1
    code = {19'b0, 1'b1, 12'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    insn = 32'b00000000101000001000001100010011; // addi x6, x1, 10
    code = {20'b0, 1'b1, 11'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    insn = 32'b01000000000100010000001110110011; // sub x7, x2, x1
    code = {19'b0, 1'b1, 12'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    insn = 32'b01000000010110100101010100010011; // srai x10, x20, 5
    code = {20'b0, 1'b1, 11'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    insn = 32'b00000000000000011110100000010111; // auipc x16, 30
    code = {26'b0, 1'b1, 5'b0};
    #5
    start = 1'b0;
    #20
    $finish;
end

endmodule