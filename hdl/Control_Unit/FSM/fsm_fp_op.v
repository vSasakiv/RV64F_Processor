module fsm_fp_op (
    input [31:0] insn, code, // instrução, e código vindo do módulo opdecoder
    input start, clk, done_fp, // sinal para que a máquina saia do IDLE, e clock
    output reg load_pc, load_fp_regfile, load_rs1_fp, load_rs2_fp, load_alu_fp,
    output reg start_add_sub_fp, start_mult_fp, sub_fp, done // seletor de entrada B da alu, e sinal de sub ou shift right aritmético
);

localparam IDLE = 3'b000;
localparam DECODE = 3'b001;
localparam EXECUTE = 3'b010;
localparam WRITEBACK = 3'b110;
localparam DONE = 3'b111;

reg [2:0] state, next;

always @(posedge clk) begin
    state <= next; // atualiza o estado a cada ciclo de clock 
end

always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? DECODE : IDLE; // apenas vamos sair do idle quando start = 1
        // dependendo do code, iremos para um estado (1 tipo de instrução) ou outro
        DECODE: next = EXECUTE;
        EXECUTE: next = done_fp ? WRITEBACK: EXECUTE;
        WRITEBACK: next = DONE;
        DONE: next = IDLE;
        default: next = IDLE;
    endcase
end

always @(state, insn, code) begin
    // inicializamos alguns valores toda vez que temos subida 
    load_pc = 1'b0;
    load_fp_regfile = 1'b0;
    load_alu_fp = 1'b0;
    load_rs1_fp = 1'b0;
    load_rs2_fp = 1'b0;
    start_add_sub_fp = 1'b0;
    start_mult_fp = 1'b0;
    sub_fp = 1'b0;
    done = 1'b0;
    case (state)
        DECODE: begin // caso o estado seja decode, ativamos os registradores na saída dos regfiles
          load_rs1_fp = 1'b1;
          load_rs2_fp = 1'b1;
        end
        EXECUTE: begin 
          sub_fp = insn[27];
          start_add_sub_fp = (insn[31:27] == 5'b0 || insn[31:27] == 5'b00001) ? 1'b1 : 1'b0;
          start_mult_fp = (insn[31:27] == 5'b00010) ? 1'b1 : 1'b0;
          load_alu_fp = 1'b1;
        end
        WRITEBACK: begin // escrevemos as mudanças no regfile, e podemos atualizar o pc
            load_pc = 1'b1;
            load_fp_regfile = 1'b1;
        end
        DONE: done = 1'b1;
        default: begin
            done = 1'b0;
        end 
    endcase
end

endmodule