/* 
Este módulo é um dos vários módulos de FSM (Máquina de estado finito)
que iram compor a Control Unit deste processador
Esta máquina de estado se especializa em lidar com todas as instruções
que executam operações Jump e Branch básicas utilizando a ALU para binários
do DataFlow, lidando assim com instruções do tipo J, tanto de 64 como 32 bits
e também com algumas instruções do tipo I, novamente, tanto de 64 como de 32 bits
e as instruções do tipo B 
*/

module fsm_branch_jump (
    input [31:0] insn, code, // instrução, e código vindo do módulo opdecoder
    input start, clk, // sinal para que a máquina saia do IDLE, e clock
    input lu, ls, eq, // flags de comparação
    output [1:0] sel_rd, // seletor rd
    output load_data_memory, sub_sra, sel_alu_a, sel_alu_b, load_alu, 
    output memory_start, sel_mem_next, sel_mem_operation,
    output reg sel_pc_next, sel_pc_increment, sel_pc_jump,  // seletores do program counter e da entrada A da alu
    output reg load_pc, load_regfile, load_rs1, load_rs2,
    output reg load_imm, load_pc_alu, load_flags, done // loads
);

localparam IDLE = 3'b000;
localparam DECODE = 3'b001;
localparam EXECUTE1 = 3'b010; // Instruções Tipo J e I (jarl)
localparam EXECUTE2 = 3'b011; // Instruções Tipo B
localparam FLAGS = 3'b100;
localparam WRITEBACK1 = 3'b101;
localparam WRITEBACK2 = 3'b110;
localparam DONE = 3'b111;

// Alguns sinais nestes tipos de instruções são constantes, logos podemos
// utilizar assign para economizar registradores

assign sel_rd = 2'b11;
assign load_data_memory = 1'b0;
assign sub_sra = 1'b0;
assign sel_alu_a = 1'b0;
assign sel_alu_b = 1'b0;
assign load_alu = 1'b0;
assign memory_start = 1'b0;
assign sel_mem_next = 1'b0;
assign sel_mem_operation = 1'b0;

reg [2:0] state, next;

always @(posedge clk) begin
    state <= next; // atualiza o estado a cada ciclo de clock 
end

always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? DECODE : IDLE; // apenas vamos sair do idle quando start = 1
        DECODE: next = (code[24] == 1'b1) ? EXECUTE2 : EXECUTE1;
        // caso seja um branch, vamos para Execute2, se for um jump, para Execute1
        EXECUTE1: next = WRITEBACK1;
        EXECUTE2: next = FLAGS;
        FLAGS: next = WRITEBACK2;
        WRITEBACK1, WRITEBACK2: next = DONE;
        DONE: next = IDLE;
        default: next = IDLE;
    endcase
end

always @(state, code, insn, eq, ls, lu) begin
    // inicializamos alguns valores toda vez que temos subida
    load_pc = 1'b0;
    load_regfile = 1'b0;
    load_flags = 1'b0;
    load_rs1 = 1'b0;
    load_rs2 = 1'b0;
    load_imm = 1'b0;
    sel_pc_next = 1'b0;
    sel_pc_jump = 1'b0;
    sel_pc_increment = 1'b0;
    load_pc_alu = 1'b0;
    done = 1'b0;
    case (state)
        DECODE: begin // caso o estado seja decode, ativamos os registradores na saída dos regfiles e imediato
            load_rs1 = 1'b1;
            load_rs2 = 1'b1;
            load_imm = 1'b1;
        end
        EXECUTE1: begin  // somamos pc + imm se for jump ou rs1 + imm se for jump and link
            load_pc_alu = 1'b1; // ativamos o registrador q irá conter pc + 4
        end
        EXECUTE2: begin // se for branch, comparamos rs1 com rs2
            load_flags = 1'b1;
        end
        WRITEBACK1: begin // Tipo J, escrevemos rd = pc + 4 e pc = (pc ou rs1) + imm (alu)
            sel_pc_jump = (code[25] == 1'b1) ? 1'b0 : 1'b1;
            load_regfile = 1'b1;
            sel_pc_next = 1'b1;
            load_pc = 1'b1;
        end
        WRITEBACK2: begin
            load_pc = 1'b1;
            case (insn[14:12])
                3'b000: sel_pc_increment = eq;
                3'b001: sel_pc_increment = ~eq;
                3'b100: sel_pc_increment = ls;
                3'b101: sel_pc_increment = ~ls;
                3'b110: sel_pc_increment = lu;
                3'b111: sel_pc_increment = ~lu;
                default: sel_pc_increment = 1'b0;
            endcase
        end
        DONE: done = 1'b1;
        default: begin
            load_pc = 1'b0;
            load_regfile = 1'b0;
            load_flags = 1'b0;
            load_rs1 = 1'b0;
            load_rs2 = 1'b0;
            load_imm = 1'b0;
            sel_pc_next = 1'b0;
            sel_pc_jump = 1'b0;
            sel_pc_increment = 1'b0;
            load_pc_alu = 1'b0;
            done = 1'b0;
        end 
    endcase
end

endmodule