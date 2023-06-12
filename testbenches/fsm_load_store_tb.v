`timescale 1 ns / 100 ps
/*
Testbench para a fsm que controla as operações de load e store
*/
module fsm_load_store_tb ();

reg [31:0] insn, code;
reg clk, start, lu, ls, eq;
reg memory_done;
wire [2:0] func3;
wire [1:0] sel_rd;
wire load_pc, load_regfile, load_rs1, load_rs2, load_alu, load_data_memory, write_mem;
wire load_imm, load_flags, load_pc_alu;
wire sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b, sub_sra;
wire sel_pc_increment, sel_pc_jump, sel_mem_next, memory_start, sel_mem_operation;

fsm_load_store UUT (
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
    .sel_mem_operation,
    .memory_done
    );

initial
    clk = 1; // Clock inicial estabelecido como 1;

always 
    #1 clk = ~clk;

initial begin
    $dumpfile("fsm.vcd"); 
    $dumpvars(20, fsm_load_store_tb);
end
initial begin
    // executamos uma simulação, dando os sinais que ela receberia numa operação real
    // em seguida é analisado o waveform gerado para verificar se o funcionamento é aceitável
    start = 1'b1;
    memory_done = 1'b1;
    insn = 32'b00000000101000000000001010000011; // lb x5, 10
    code = {31'b0, 1'b1};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    insn = 32'b00000000101000001010001100100011; // sw x10, 6(x1)
    code = {23'b0, 1'b1, 8'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    insn = 32'b00000000000000101101101110110111; // lui x23, 45
    code = {18'b0, 1'b1, 13'b0};
    #5
    start = 1'b0;
    #20
    $finish;
end

endmodule