/* 
Este módulo é um dos vários módulos de FSM (Máquina de estado finito)
que iram compor a Control Unit deste processador
Esta máquina de estado se especializa em lidar com todas as instruções
que executam operações load e store básicas utilizando a ALU para binários
do DataFlow, lidando assim com instruções do tipo S, tanto de 64 como 32 bits
e também com algumas instruções do tipo I, novamente, tanto de 64 como de 32 bits
e a instrução lui do tipo U.
*/

module fsm_load_store (
    input [31:0] ins, code, // instrução, e código vindo do módulo opdecoder
    input start, clk, // sinal para que a máquina saia do IDLE, e clock
    input lu, ls, eq, // flags de comparação
    output [2:0] func3, // seletor função da alu
    output reg [1:0] sel_rd, // seletor rd
	output sub_sra, sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b,// seletores do program counter e da entrada A da alu
    output reg load_pc, load_regfile, load_rs1, load_rs2, load_alu, load_data_memory, write_mem // loads
);

localparam IDLE = 3'b000;
localparam DECODE = 3'b001;
localparam EXECUTE = 3'b010; // Instruções Tipo S
localparam EXECUTE2 = 3'b011; // Instruções Tipo I load
localparam MEMORY1 = 3'b101; // Memory write
localparam MEMORY2 = 3'b110; // Memory load
localparam WRITEBACK = 3'b111;

// Alguns sinais nestes tipos de instruções são constantes, logos podemos
// utilizar assign para economizar registradores

assign func3 = 3'b000;
assign sub_sra = 1'b0;
assign sel_alu_a = 1'b0;
assign sel_alu_b = 1'b1;
assign sel_pc_next = 1'b0;
assign sel_pc_alu = 1'b0;

reg [2:0] state, next;

always @(posedge clk) begin
    state <= next; // atualiza o estado a cada ciclo de clock 
end

always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? DECODE : IDLE; // apenas vamos sair do idle quando start = 1
        DECODE: next = (code[13] == 1'b1) ? WRITEBACK : EXECUTE;
        // caso seja do tipo lui, podemos ir direto para o writeback, já que a instrução não precisa de execução 
        EXECUTE: next = (code[8] == 1'b1) ? MEMORY1 : MEMORY2;
        // caso seja store, vamos para memory 1, caso seja load, para memory 2
        MEMORY1, MEMORY2: next = WRITEBACK;
        WRITEBACK: next = IDLE;
        default: next = IDLE;
    endcase
end

always @(posedge clk) begin
    // inicializamos alguns valores toda vez que temos subida
    sel_rd <= 2'b00; 
    load_pc <= 1'b0;
    load_regfile <= 1'b0;
    load_alu <= 1'b0;
    load_rs1 <= 1'b0;
    load_rs2 <= 1'b0;
    load_data_memory <= 1'b0;
    write_mem <= 1'b0;
    case (next)
        IDLE: begin
            sel_rd <= 2'b00;
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            load_data_memory <= 1'b0;
            write_mem <= 1'b0;
        end 
        DECODE: begin // caso o estado seja decode, ativamos os registradores na saída dos regfiles
            load_rs1 <= 1'b1;
            load_rs2 <= 1'b1;
        end
        EXECUTE: begin  // somamos imm no rs1 para obter endereço
            load_alu <= 1'b1; // ativamos o registrador na saída da alu
        end
        MEMORY1: begin // caso seja tipo S, carregamos na memória o valor no endereço da soma
            write_mem <= 1'b1;
        end
        MEMORY2: begin // caso seja tipo I (load), carregamos o registrador da memória com o valor no endereço da soma
            load_data_memory <= 1'b1;
        end
        WRITEBACK: begin // escrevemos as mudanças no regfile, e podemos atualizar o pc
            load_pc <= 1'b1;
            load_regfile <= (code[0] == 1'b1 || code[13] == 1'b1) ? 1'b1 : 1'b0; // apenas atualizamos o regfile se for load
            sel_rd <= (code[13] == 1'b1) ? 2'b01 : 2'b00; // caso seja lui, mudamos o rd sel para o imediato
        end
        default: begin
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            load_data_memory <= 1'b0;
            write_mem <= 1'b0;
        end 
    endcase
end

endmodule