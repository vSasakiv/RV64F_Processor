`timescale 1 ns / 100 ps
/*
Testbench para a fsm que controla as operações da alu
*/
module fsm_alu_tb ();

reg [31:0] ins, code;
reg clk, start, lu, ls, eq;
wire [4:0] rs1_addr, rs2_addr, rd_addr;
wire [2:0] sel_mem_extension, func3;
wire [1:0] sel_mem_size, sel_rd;
wire load_pc, load_regfile, load_rs1, load_rs2, load_alu;
wire sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b, sub_sra;

fsm_alu UUT (
    ins,
    code, 
    start, 
    clk, 
    lu, 
    ls, 
    eq, 
    rs1_addr, 
    rs2_addr, 
    rd_addr, 
    sel_mem_extension, 
    func3, 
    sel_mem_size, 
    sel_rd, 
    load_pc, 
    load_regfile, 
    load_rs1, 
    load_rs2, 
    load_alu, 
    sel_pc_next, 
    sel_pc_alu, 
    sel_alu_a, 
    sel_alu_b, 
    sub_sra
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
    ins = 32'b00000000000100010000001010110011; // add x5, x2, x1
    code = {19'b0, 1'b1, 12'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b00000000101000001000001100010011; // addi x6, x1, 10
    code = {20'b0, 1'b1, 11'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b01000000000100010000001110110011; // sub x7, x2, x1
    code = {19'b0, 1'b1, 12'b0};
    #5
    start = 1'b0;
    #20
    start = 1'b1;
    ins = 32'b01000000010110100101010100010011; // srai x10, x20, 5
    code = {20'b0, 1'b1, 11'b0};
    #5
    start = 1'b0;
    #20
    $stop;
end

endmodule