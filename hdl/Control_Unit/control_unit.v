module control_unit (
    input [31:0] insn,
    input clk, memory_done, start, reset,
    input lu, ls, eq,
    output [31:0] code,
    output [4:0] rs1_addr, rs2_addr, rd_addr,
    output [2:0] sel_mem_extension, func3,
    output reg [1:0] sel_rd, sel_mem_size,// seletor rd
	output reg sub_sra, sel_pc_next, sel_alu_a, sel_alu_b, load_pc_alu, load_flags,
    output reg sel_pc_increment, sel_pc_jump,// seletores do program counter e da entrada A da alu
    output reg load_pc, load_regfile, load_rs1, load_rs2, load_alu, load_imm, load_ins,
    output reg load_data_memory, memory_start, sel_mem_next, sel_mem_operation
);
    localparam IDLE = 2'b00;
    localparam FETCH = 2'b01;
    localparam LOAD_IR = 2'b10;
    localparam FSM = 2'b11;

    reg [2:0] start_fsm; // start_fsm[0] = fsm_alu, start_fsm[1] = fsm_branch_jump, start_fsm[2] = fsm_load_store
    reg [1:0] state, next;
    reg fsm_done;
    
    always @(posedge clk) begin
        state <= next;    
    end

    always @* begin
        case (state)
            IDLE: next = (start == 1'b1) ? FETCH : IDLE;
            FETCH: next = (memory_done == 1'b1) ? LOAD_IR : FETCH;
            LOAD_IR: next = FSM;
            FSM: next = (fsm_done == 1'b1) ? FETCH : FSM;
            default next = IDLE;
        endcase
        if (reset) next = IDLE;
    end
    
    always @(state, code, insn, sel_rd_fsm, sub_sra_fsm, sel_pc_next_fsm,
    sel_alu_a_fsm, sel_alu_b_fsm, load_pc_alu_fsm, load_flags_fsm, sel_pc_increment_fsm,
    sel_pc_jump_fsm, load_pc_fsm, load_regfile_fsm, load_rs1_fsm, load_rs2_fsm, 
    load_alu_fsm, load_imm_fsm, load_data_memory_fsm, memory_start_fsm, sel_mem_next_fsm,
    sel_mem_operation_fsm, done_fsm) begin
        sel_mem_size = 2'b10; // tamanho w (32bits)
        start_fsm = 3'b000;
        fsm_done = 1'b0;
        load_ins = 1'b0;
        /* fsm signals */
        sel_rd = 2'b00;
        sub_sra = 1'b0;
        sel_pc_next = 1'b0;
        sel_alu_a = 1'b0;
        sel_alu_b = 1'b0;
        load_pc_alu = 1'b0;
        load_flags = 1'b0;
        sel_pc_increment = 1'b0;
        sel_pc_jump = 1'b0;
        load_pc = 1'b0;
        load_regfile = 1'b0;
        load_rs1 = 1'b0;
        load_rs2 = 1'b0;
        load_alu = 1'b0;
        load_imm = 1'b0;
        load_data_memory = 1'b0;
        memory_start = 1'b0;
        sel_mem_next = 1'b0;
        sel_mem_operation = 1'b0;

        case (state)
            FETCH: begin
                memory_start = 1'b1;
            end
            LOAD_IR: begin
                load_ins = 1'b1;
            end
            FSM: begin
                start_fsm[0] = code[12] | code[4] | code[5];
                start_fsm[1] = code[27] | code[25] | code[24];
                start_fsm[2] = code[13] | code[8] | code[0];
                sel_mem_size      = insn[13:12];
                sel_rd            = sel_rd_fsm;
                load_pc           = load_pc_fsm;
                load_regfile      = load_regfile_fsm;
                load_rs1          = load_rs1_fsm;
                load_rs2          = load_rs2_fsm;
                load_alu          = load_alu_fsm;
                load_imm          = load_imm_fsm;
                load_flags        = load_flags_fsm;
                load_pc_alu       = load_pc_alu_fsm;
                sel_pc_next       = sel_pc_next_fsm;
                sel_alu_a         = sel_alu_a_fsm;
                sel_alu_b         = sel_alu_b_fsm;
                sub_sra           = sub_sra_fsm;
                load_data_memory  = load_data_memory_fsm;
                sel_pc_increment  = sel_pc_increment_fsm;
                sel_pc_jump       = sel_pc_jump_fsm;
                sel_mem_next      = sel_mem_next_fsm;
                memory_start      = memory_start_fsm;
                sel_mem_operation = sel_mem_operation_fsm;
                fsm_done          = done_fsm;
            end
            default: begin
                sel_mem_size = 2'b10; 
                start_fsm = 3'b000;
                load_ins = 1'b0;
                /* fsm signals */
                sel_rd = 2'b00;
                sub_sra = 1'b0;
                sel_pc_next = 1'b0;
                sel_alu_a = 1'b0;
                sel_alu_b = 1'b0;
                load_pc_alu = 1'b0;
                load_flags = 1'b0;
                sel_pc_increment = 1'b0;
                sel_pc_jump = 1'b0;
                load_pc = 1'b0;
                load_regfile = 1'b0;
                load_rs1 = 1'b0;
                load_rs2 = 1'b0;
                load_alu = 1'b0;
                load_imm = 1'b0;
                load_data_memory = 1'b0;
                memory_start = 1'b0;
                sel_mem_next = 1'b0;
                sel_mem_operation = 1'b0;
                fsm_done = 1'b0;
            end
        endcase
    end

    /* FSM DECLARATIONS */

    wire [1:0] sel_rd_fsm;
    wire sub_sra_fsm;
    wire sel_pc_next_fsm;
    wire sel_alu_a_fsm;
    wire sel_alu_b_fsm;
    wire load_pc_alu_fsm;
    wire load_flags_fsm;
    wire sel_pc_increment_fsm;
    wire sel_pc_jump_fsm;
    wire load_pc_fsm;
    wire load_regfile_fsm;
    wire load_rs1_fsm;
    wire load_rs2_fsm;
    wire load_alu_fsm;
    wire load_imm_fsm;
    wire load_data_memory_fsm;
    wire memory_start_fsm;
    wire sel_mem_next_fsm;
    wire sel_mem_operation_fsm;
    wire done_fsm;

    fsm_combined FSM_COMBINED (
        .insn             (insn),
        .code             (code), 
        .start            (start_fsm), 
        .clk              (clk), 
        .lu               (lu), 
        .ls               (ls), 
        .eq               (eq),
        .sel_rd           (sel_rd_fsm),
        .load_pc          (load_pc_fsm),
        .load_regfile     (load_regfile_fsm),
        .load_rs1         (load_rs1_fsm),
        .load_rs2         (load_rs2_fsm),
        .load_alu         (load_alu_fsm),
        .load_imm         (load_imm_fsm),
        .load_flags       (load_flags_fsm),
        .load_pc_alu      (load_pc_alu_fsm),
        .sel_pc_next      (sel_pc_next_fsm),
        .sel_alu_a        (sel_alu_a_fsm),
        .sel_alu_b        (sel_alu_b_fsm),
        .sub_sra          (sub_sra_fsm),
        .load_data_memory (load_data_memory_fsm),
        .sel_pc_increment (sel_pc_increment_fsm),
        .sel_pc_jump      (sel_pc_jump_fsm),
        .sel_mem_next     (sel_mem_next_fsm),
        .memory_start     (memory_start_fsm),
        .sel_mem_operation(sel_mem_operation_fsm),
        .memory_done      (memory_done),
        .done             (done_fsm)
    );

    /*  CONSTANT ASSIGNMENTS   */

    assign rs1_addr = insn[19:15];
    assign rs2_addr = insn[24:20];
    assign rd_addr = insn[11:7];
    assign func3 = (code[0] == 1'b1 || code[8] == 1'b1) ? 3'b000 : insn[14:12];
    assign sel_mem_extension = insn[14:12];

    /*   OPCDECODER   */
    opdecoder OPDEC (
        .opcode(insn[6:0]),
        .code  (code)
    );

endmodule