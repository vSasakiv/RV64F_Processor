/*
    Módulo representado o bloco program_counter e todos os seus somadores
    e moultiplexadores
*/
module program_counter (
    input clk, reset, load_pc, // entradas clock, reset e load para o registrador
    input sel_pc_next, sel_pc_increment, sel_pc_jump, // seletores de multiplexadores
    input [63:0] imm_value, rs1_value, // valores do imediato, e vindos do rs1
    output [63:0] pc_value, pc_alu_o // saída do valor atual do pc, e do valor do pc incrementado
);

    wire [63:0] pc_increment_value, pc_jump_increment;
    wire [63:0] pc_next_branch, pc_next_jump, pc_next;
    
    // Registrador program counter com reset
    reg_async_reset #(.Size(64)) pc (
        .clk    (clk),
        .reset  (reset),
        .load   (load_pc),
        .data_i (pc_next),
        .data_o (pc_value)
    );

    // Mux que seleciona se o valor atual será somado com imediato, ou apenas +4
    mux_2to1 #(.Size(64)) mux_pc_increment (
        .sel    (sel_pc_increment),
        .i0     (64'h00000004),
        .i1     (imm_value),
        .data_o (pc_increment_value)
    );
    // Mux que seleciona se devemos incrementar de rs1 (jalr) ou imm (jal)
    mux_2to1 #(.Size(64)) mux_jump (
        .sel    (sel_pc_jump),
        .i0     (rs1_value),
        .i1     (pc_value),
        .data_o (pc_jump_increment)
    );

    // Mux que seleciona qual o próximo valor deve ser
    mux_2to1 #(.Size(64)) mux_sel_pc (
        .sel    (sel_pc_next),
        .i0     (pc_next_branch),
        .i1     (pc_next_jump),
        .data_o (pc_next)
    );

    // Somador que soma rs1 ou pc ao imm
    adder64b pc_jump_increment_adder (
        .a   (pc_jump_increment),
        .b   (imm_value),
        .sub (1'b0),
        .s   (pc_next_jump)
    );

    // Somador que soma 
    adder64b pc_branch_increment_adder (
        .a   (pc_increment_value),
        .b   (pc_value),
        .sub (1'b0),
        .s   (pc_next_branch)
    );

    assign pc_alu_o = pc_next_branch;

endmodule