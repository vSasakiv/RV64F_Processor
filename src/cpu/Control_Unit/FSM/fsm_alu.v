/* 
Este módulo é um dos vários módulos de FSM (Máquina de estado finito)
que iram compor a Control Unit deste processador
Esta máquina de estado se especializa em lidar com todas as instruções
que executam operações aritméticas básicas utilizando a ALU para binários
do DataFlow, lidando assim com algumas das instruções do tipo R, tanto de 64 como 32 bits
e também com algumas instruções do tipo I, novamente, tanto de 64 como de 32 bits
e da instrução AUIPC do tipo U
*/

module fsm_alu (
    input [31:0] ins, code, // instrução, e código vindo do módulo opdecoder
    input start, clk, // sinal para que a máquina saia do IDLE, e clock
    input lu, ls, eq, // flags de comparação
    output [2:0] func3, // func3
    output [1:0] sel_rd, // seletor rd
	output sel_pc_next, sel_pc_alu, load_data_memory, write_mem, load_pc_alu, load_flags, // seletores do program counter e da entrada A da alu
    output reg load_pc, load_regfile, load_rs1, load_rs2, load_alu, load_imm,// loads
    output reg sel_alu_a, sel_alu_b, sub_sra // seletor de entrada B da alu, e sinal de sub ou shift right aritmético
);

localparam IDLE = 3'b000;
localparam DECODE = 3'b001;
localparam EXECUTE1 = 3'b010; // Instruções Tipo R alu 64 bits
localparam EXECUTE2 = 3'b011; // Instruções Tipo I alu 64 bits
localparam WRITEBACK = 3'b111;

// Alguns sinais nestes tipos de instruções são constantes, logos podemos
// utilizar assign para economizar registradores

assign func3 = ins[14:12];
assign sel_rd = 2'b10;
assign sel_pc_next = 1'b0;
assign load_pc_alu = 1'b0;
assign load_flags = 1'b0;
assign sel_pc_alu = 1'b0;
assign load_data_memory = 1'b0;
assign write_mem = 1'b0;

reg [2:0] state, next;

always @(posedge clk) begin
    state <= next; // atualiza o estado a cada ciclo de clock 
end

always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? DECODE : IDLE; // apenas vamos sair do idle quando start = 1
        // dependendo do code, iremos para um estado (1 tipo de instrução) ou outro
        DECODE: next = (code[12] == 1'b1) ? EXECUTE1 : EXECUTE2; 
        EXECUTE1: next = WRITEBACK;
		EXECUTE2: next = WRITEBACK;
        WRITEBACK: next = IDLE;
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
    load_imm <= 1'b0;
    sel_alu_a <= 1'b0;
    sel_alu_b <= 1'b0;
    sub_sra <= 1'b0;
    case (next)
        IDLE: begin
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            load_imm <= 1'b0;
            sel_alu_a <= 1'b0;
            sel_alu_b <= 1'b0;
            sub_sra <= 1'b0;
        end 
        DECODE: begin // caso o estado seja decode, ativamos os registradores na saída dos regfiles
            load_rs1 <= 1'b1;
            load_rs2 <= 1'b1;
            load_imm <= 1'b1;
        end
        EXECUTE1: begin 
            load_alu <= 1'b1; // ativamos o registrador na saída da alu
            sub_sra <= ins[30]; // sub_sra pode ser obtido diretamente da instrução
            sel_alu_b <= 1'b0; // seletor em b é sempre 0 para instruções tipo R
        end
        EXECUTE2: begin
            load_alu <= 1'b1; // ativamos o registrador na saída da alu
            sub_sra <= (ins[14:12] == 3'b101 && code[5] == 1'b0) ? 1'b1 : 1'b0; // sub_sra depende do func3 (srai)
            sel_alu_a <= (code[5] == 1'b1) ? 1'b1 : 1'b0; // caso seja auipc, entrada A da alu vira o pc
            sel_alu_b <= 1'b1; // seletor em b é sempre 1 para instruções tipo I
        end
        WRITEBACK: begin // escrevemos as mudanças no regfile, e podemos atualizar o pc
            load_pc <= 1'b1;
            load_regfile <= 1'b1;
        end
        default: begin
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            load_imm <= 1'b0;
            sel_alu_a <= 1'b0;
            sel_alu_b <= 1'b0;
            sub_sra <= 1'b0;
        end 
    endcase
end

endmodule