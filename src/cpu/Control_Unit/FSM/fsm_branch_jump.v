/* 
Este módulo é um dos vários módulos de FSM (Máquina de estado finito)
que iram compor a Control Unit deste processador
Esta máquina de estado se especializa em lidar com todas as instruções
que executam operações load e store básicas utilizando a ALU para binários
do DataFlow, lidando assim com instruções do tipo S, tanto de 64 como 32 bits
e também com algumas instruções do tipo I, novamente, tanto de 64 como de 32 bits
e a instrução lui do tipo U.
*/

module fsm_branch_jump (
    input [31:0] ins, code, // instrução, e código vindo do módulo opdecoder
    input start, clk, // sinal para que a máquina saia do IDLE, e clock
    input lu, ls, eq, // flags de comparação
    output [2:0] func3, // seletor função da alu
    output [1:0] sel_rd, // seletor rd
    output load_data_memory, write_mem,
	output reg sel_pc_next, sel_pc_alu,  // seletores do program counter e da entrada A da alu
    output reg load_pc, sub_sra, load_regfile, load_rs1, load_rs2, load_alu, sel_alu_a, sel_alu_b, load_pc_alu // loads
);

localparam IDLE = 3'b000;
localparam DECODE = 3'b001;
localparam EXECUTE1 = 3'b010; // Instruções Tipo J e I (jarl)
localparam EXECUTE2 = 3'b011; // Instruções Tipo B
localparam WRITEBACK1 = 3'b110;
localparam WRITEBACK2 = 3'b111;

// Alguns sinais nestes tipos de instruções são constantes, logos podemos
// utilizar assign para economizar registradores

assign func3 = 3'b000;
assign sel_rd = 2'b11;
reg [2:0] state, next;

always @(posedge clk) begin
    state <= next; // atualiza o estado a cada ciclo de clock 
end

always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? DECODE : IDLE; // apenas vamos sair do idle quando start = 1
        DECODE: next = (code[24] == 1'b1) ? EXECUTE2 : EXECUTE1;
        // caso seja do tipo lui, podemos ir direto para o writeback1, já que a instrução não precisa de execução 
        EXECUTE1: next = WRITEBACK1;
        EXECUTE2: next = WRITEBACK2;
        // caso seja store, vamos para memory 1, caso seja load, para memory 2
        WRITEBACK1, WRITEBACK2: next = IDLE;
        default: next = IDLE;
    endcase
end

always @(posedge clk) begin
    // inicializamos alguns valores toda vez que temos subida
    load_pc <= 1'b0;
    load_regfile <= 1'b0;
    load_alu <= 1'b0;
    load_rs1 <= 1'b0;
    load_rs2 <= 1'b0;
    sel_pc_alu <= 1'b0;
    sel_pc_next <= 1'b0;
    sub_sra <= 1'b0;
    sel_alu_a <= 1'b0;
    sel_alu_b <= 1'b0;
    load_pc_alu <= 1'b0;
    case (next)
        IDLE: begin
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            sel_pc_alu <= 1'b0;
            sel_pc_next <= 1'b0;
            sub_sra <= 1'b0;
            sel_alu_a <= 1'b0;
            sel_alu_b <= 1'b0;
            load_pc_alu <= 1'b0;
        end 
        DECODE: begin // caso o estado seja decode, ativamos os registradores na saída dos regfiles
            load_rs1 <= 1'b1;
            load_rs2 <= 1'b1;
        end
        EXECUTE1: begin  // somamos pc + imm se for jump ou rs1 + imm se for jump and link
            sel_alu_a <= (code[25] == 1'b1) ? 1'b0 : 1'b1;
            sel_alu_b <= 1'b1;
            load_alu <= 1'b1; // ativamos o registrador na saída da alu
            load_pc_alu <= 1'b1; // ativamos o registrador q irá conter pc + 4
        end
        EXECUTE2: begin // se for branch, comparamos rs1 com rs2
            sub_sra <= 1'b1;
        end
        WRITEBACK1: begin // Tipo J, escrevemos rd = pc + 4 e pc = (pc ou rs1) + imm (alu)
            load_regfile <= 1'b1;
            sel_pc_next <= 1'b1;
            load_pc <= 1'b1;
        end
        WRITEBACK2: begin
            load_pc <= 1'b1;
            case (ins[14:12])
                3'b000: sel_pc_alu <= eq;
                3'b001: sel_pc_alu <= ~eq;
                3'b100: sel_pc_alu <= ls;
                3'b101: sel_pc_alu <= ~ls;
                3'b110: sel_pc_alu <= lu;
                3'b111: sel_pc_alu <= ~lu;
                default: sel_pc_alu <= 1'b0;
            endcase
        end
        default: begin
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            sel_pc_alu <= 1'b0;
            sel_pc_next <= 1'b0;
            sub_sra <= 1'b0;
            sel_alu_a <= 1'b0;
            sel_alu_b <= 1'b0;
            load_pc_alu <= 1'b0;
        end 
    endcase
end

endmodule