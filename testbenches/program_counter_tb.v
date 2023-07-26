`timescale 1ns/100ps
/*
    Testbench para módulo com program_counter e seus componentes
*/
module program_counter_tb();

reg clk, load_pc, reset;
reg sel_pc_increment, sel_pc_next, sel_pc_jump;
reg [63:0] rs1_value, imm_value;
wire [63:0] pc_value, pc_alu_o;

program_counter UUT (
    .clk              (clk),
    .load_pc          (load_pc),
    .reset            (reset),
    .sel_pc_increment (sel_pc_increment),
    .sel_pc_next      (sel_pc_next),
    .sel_pc_jump      (sel_pc_jump),
    .rs1_value        (rs1_value),
    .imm_value        (imm_value),
    .pc_value         (pc_value),
    .pc_alu_o         (pc_alu_o)
);

always #5 clk = ~clk; // gera sinal clock com periodo 10

initial begin
    $dumpfile("pc.vcd");
    $dumpvars(1000, program_counter_tb);
    clk = 0;
    reset = 1'b1;
    #10;
    // pc deve receber pc + 4 (0x00 + 0x04 = 0x04)
    reset = 1'b0;
    sel_pc_increment = 1'b0;
    sel_pc_next = 1'b0;
    load_pc = 1'b1;
    #10;
    // pc deve receber pc + imm (0x04 + 0x12 = 0x16)
    sel_pc_increment = 1'b1;
    imm_value = 64'h00000012;
    #10
    // pc deve receber imm + rs1 (0x12 + 0x01 = 0x13)
    sel_pc_next = 1'b1;
    sel_pc_jump = 1'b0;
    rs1_value = 64'h00000001;
    #10
    // pc deve receber pc + imm (0x13 + 0x12 = 0x25)
    sel_pc_jump = 1'b1;
    #10
    $finish;
end

endmodule