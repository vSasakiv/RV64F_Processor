module execute_fsm(
    input [31:0] code, insn,
    input start,
    input clk, memory_done, done_fp,
    input lu, ls, eq,
    output reg [1:0] sel_rd, // seletor rd
    output reg sub_sra, sel_pc_next, sel_alu_a, sel_alu_b, load_pc_alu, load_flags,
    output reg sel_pc_increment, sel_pc_jump, sel_alu_32b,// seletores do program counter e da entrada A da alu
    output reg load_pc, load_regfile, load_alu, load_reg,
    output reg load_regfile_fp, sel_store_fp, sel_rd_fp,
    output reg start_add_sub_fp, start_mult_fp, load_alu_fp, sub_fp,
    output reg load_data_memory, memory_start, sel_mem_next, sel_mem_operation, done
);

    localparam IDLE = 5'b00001;
    localparam R_TYPE = 5'b00010;
    localparam I_OP_TYPE = 5'b00011;
    localparam JUMP_TYPE = 5'b00100;
    localparam BRANCH_TYPE = 5'b00101;
    localparam FLAGS = 5'b00110;
    localparam LOAD_TYPE = 5'b00111;
    localparam STORE_TYPE = 5'b01000;
    localparam MEMORY_LOAD = 5'b01001;
    localparam MEMORY_STORE = 5'b01010;
    localparam FLOAT_OP_TYPE  = 5'b01011;
    localparam WRITEBACK_LOAD_STORE = 5'b11011;
    localparam WIRTEBACK_BRANCH = 5'b11100;
    localparam WRITEBACK_JUMP = 5'b11101;
    localparam WRITEBACK_FP = 5'b11110;
    localparam WRITEBACK = 5'b11111;

    reg [4:0] state, next;

    always @* begin
        case (state)
            IDLE: begin
                if (start) begin
                    if (code[12] || code[14]) next = R_TYPE;
                    else if (code[4] || code[6]) next = I_OP_TYPE;
                    else if (code[25] || code[27]) next = JUMP_TYPE;
                    else if (code[24]) next = BRANCH_TYPE;
                    else if (code[0] || code[1]) next = LOAD_TYPE;
                    else if (code[8] || code[9]) next = STORE_TYPE;
                    else if (code[20]) next = FLOAT_OP_TYPE;
                    else next = IDLE;
                end else next = IDLE;
            end
            R_TYPE: next = WRITEBACK;
            I_OP_TYPE: next = WRITEBACK;
            JUMP_TYPE: next = WRITEBACK_JUMP;
            BRANCH_TYPE: next = FLAGS;
            FLAGS: next = WIRTEBACK_BRANCH;
            LOAD_TYPE: next = MEMORY_LOAD;
            STORE_TYPE: next = MEMORY_STORE;
            MEMORY_LOAD: next = memory_done ? WRITEBACK_LOAD_STORE : MEMORY_LOAD;
            MEMORY_STORE: next = memory_done ? WRITEBACK_LOAD_STORE : MEMORY_STORE;
            FLOAT_OP_TYPE: next = done_fp ? WRITEBACK_FP : FLOAT_OP_TYPE;
            WRITEBACK, WRITEBACK_JUMP, WRITEBACK_FP, WIRTEBACK_BRANCH, WRITEBACK_LOAD_STORE: next = IDLE;
            default: next = IDLE;
        endcase
    end

    always @(state) begin
        sel_rd = 2'b00;
        sub_sra = 1'b0;
        sel_pc_next = 1'b0;
        sel_alu_a = 1'b0;
        sel_alu_b = 1'b0;
        load_pc_alu = 1'b0;
        load_flags = 1'b0;
        sel_pc_increment = 1'b0;
        sel_pc_jump = 1'b0;
        sel_alu_32b = 1'b0;
        load_pc = 1'b0;
        load_reg = 1'b0;
        load_regfile = 1'b0;
        load_alu = 1'b0;
        load_regfile_fp = 1'b0;
        sel_store_fp = 1'b0;
        sel_rd_fp = 1'b0;
        start_add_sub_fp = 1'b0;
        start_mult_fp = 1'b0;
        load_alu_fp = 1'b0;
        sub_fp = 1'b0;
        load_data_memory = 1'b0;
        memory_start = 1'b0;
        sel_mem_next = 1'b0;
        sel_mem_operation = 1'b0;
        done = 1'b0;
        case (state)
            IDLE: begin
                load_reg = 1'b1;
            end
            R_TYPE: begin
                load_alu = 1'b1; // ativamos o registrador na saída da alu
                sub_sra = insn[30]; //sub_sra deve ser para instruções sub e sra
                sel_alu_b = 1'b0; // seletor em b é sempre 0 para instruções tipo R
                sel_alu_32b = code[14]; // liga seletor para instruções tipo word
            end
            I_OP_TYPE: begin
                load_alu = 1'b1; // ativamos o registrador na saída da alu
                sub_sra = (insn[14:12] == 3'b101) ? insn[30]: 1'b0; // caso seja srai, depende da ins
                sel_alu_a = (code[5] == 1'b1) ? 1'b1 : 1'b0; // caso seja auipc, entrada A da alu vira o pc
                sel_alu_b = 1'b1; // seletor em b é sempre 1 para instruções tipo I
                sel_alu_32b = code[6]; // liga seletor para instruções tipo word
            end
            WRITEBACK: begin
                sel_rd = 2'b10;
                load_pc = 1'b1;
                load_regfile = 1'b1;
                done = 1'b1;
            end

            JUMP_TYPE: begin // somamos pc + imm se for jump ou rs1 + imm se for jump and link
                load_pc_alu = 1'b1; // ativamos o registrador q irá conter pc + 4
            end
            WRITEBACK_JUMP: begin // Tipo J, escrevemos rd = pc + 4 e pc = (pc ou rs1) + imm (alu)
                done = 1'b1;
                sel_rd = 2'b11;
                sel_pc_jump = (code[25] == 1'b1) ? 1'b0 : 1'b1;
                load_regfile = 1'b1;
                sel_pc_next = 1'b1;
                load_pc = 1'b1;
            end

            BRANCH_TYPE: begin // se for branch, comparamos rs1 com rs2
                load_flags = 1'b1;
            end
            WIRTEBACK_BRANCH: begin
                done = 1'b1;
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

            LOAD_TYPE, STORE_TYPE: begin // somamos imm no rs1 para obter endereço
                sel_alu_b = 1'b1;
                load_alu = 1'b1; // ativamos o registrador na saída da alu
            end
            MEMORY_LOAD: begin // caso seja tipo I (load), carregamos o registrador da memória com o valor no endereço da soma
                memory_start = 1'b1;
                sel_mem_next = 1'b1;
                load_data_memory = 1'b1;
            end
            MEMORY_STORE: begin // caso seja tipo S, carregamos na memória o valor no endereço da soma
                memory_start = 1'b1;
                sel_mem_next = 1'b1;
                sel_mem_operation = 1'b1;
            end
            WRITEBACK_LOAD_STORE: begin
                // escrevemos as mudanças no regfile, e podemos atualizar o pc
                load_pc = 1'b1;
                load_regfile = (code[0] == 1'b1 || code[13] == 1'b1) ? 1'b1 : 1'b0; // apenas atualizamos o regfile se for load
                load_regfile_fp = code[1] ? 1'b1 : 1'b0;
                sel_rd_fp = code[1] ? 1'b1 : 1'b0;
                sel_rd = (code[13] == 1'b1) ? 2'b01 : 2'b00; // caso seja lui, mudamos o rd sel para o imediato
            end

            FLOAT_OP_TYPE: begin
                sub_fp = insn[27];
                start_add_sub_fp = (insn[31:27] == 5'b0 || insn[31:27] == 5'b00001) ? 1'b1 : 1'b0;
                start_mult_fp = (insn[31:27] == 5'b00010) ? 1'b1 : 1'b0;
                load_alu_fp = 1'b1;
            end
            WRITEBACK_FP: begin
                load_pc = 1'b1;
                load_regfile_fp = 1'b1;
            end

            default: done = 1'b0;
        endcase
    end


endmodule