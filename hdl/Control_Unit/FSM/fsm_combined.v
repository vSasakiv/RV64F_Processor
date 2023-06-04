module fsm_combined (
    input [31:0] code, insn,
    input [2:0] start,
    input clk, memory_done,
    input lu, ls, eq,
    output [1:0] sel_rd, // seletor rd
	output sub_sra, sel_pc_next, sel_alu_a, sel_alu_b, load_pc_alu, load_flags,
    output sel_pc_increment, sel_pc_jump,// seletores do program counter e da entrada A da alu
    output load_pc, load_regfile, load_rs1, load_rs2, load_alu, load_imm, 
    output load_data_memory, memory_start, sel_mem_next, sel_mem_operation, done
);
    // index 0 -> idle (all loads = 0)
    // index 1 -> fsm_alu
    // index 2 -> fsm_branch_jump
    // index 3 -> fsm_load_store
    reg [1:0] index;
    wire [1:0] sel_rd_array [3:0];
    wire sub_sra_array [3:0];
    wire sel_pc_next_array [3:0];
    wire sel_alu_a_array [3:0];
    wire sel_alu_b_array [3:0];
    wire load_pc_alu_array [3:0];
    wire load_flags_array [3:0];
    wire sel_pc_increment_array [3:0];
    wire sel_pc_jump_array [3:0];
    wire load_pc_array [3:0];
    wire load_regfile_array [3:0];
    wire load_rs1_array [3:0];
    wire load_rs2_array [3:0];
    wire load_alu_array [3:0];
    wire load_imm_array [3:0];
    wire load_data_memory_array [3:0];
    wire memory_start_array [3:0];
    wire sel_mem_next_array [3:0];
    wire sel_mem_operation_array [3:0];
    wire done_array [3:0];

    always @(start) begin
        case (start)
            3'b001: index = 2'b01;
            3'b010: index = 2'b10;
            3'b100: index = 2'b11;
            default: index = 2'b00;
        endcase
    end
    
    fsm_alu FSM_ALU (
        .insn             (insn),
        .code             (code), 
        .start            (start[0]), 
        .clk              (clk), 
        .lu               (lu), 
        .ls               (ls), 
        .eq               (eq),
        .sel_rd           (sel_rd_array[1]),
        .load_pc          (load_pc_array[1]),
        .load_regfile     (load_regfile_array[1]),
        .load_rs1         (load_rs1_array[1]),
        .load_rs2         (load_rs2_array[1]),
        .load_alu         (load_alu_array[1]),
        .load_imm         (load_imm_array[1]),
        .load_flags       (load_flags_array[1]),
        .load_pc_alu      (load_pc_alu_array[1]),
        .sel_pc_next      (sel_pc_next_array[1]),
        .sel_alu_a        (sel_alu_a_array[1]),
        .sel_alu_b        (sel_alu_b_array[1]),
        .sub_sra          (sub_sra_array[1]),
        .load_data_memory (load_data_memory_array[1]),
        .sel_pc_increment (sel_pc_increment_array[1]),
        .sel_pc_jump      (sel_pc_jump_array[1]),
        .sel_mem_next     (sel_mem_next_array[1]),
        .memory_start     (memory_start_array[1]),
        .sel_mem_operation(sel_mem_operation_array[1]),
        .done             (done_array[1])
    );
    fsm_branch_jump FSM_BRANCH_JUMP (
        .insn             (insn),
        .code             (code), 
        .start            (start[1]), 
        .clk              (clk), 
        .lu               (lu), 
        .ls               (ls), 
        .eq               (eq),
        .sel_rd           (sel_rd_array[2]),
        .load_pc          (load_pc_array[2]),
        .load_regfile     (load_regfile_array[2]),
        .load_rs1         (load_rs1_array[2]),
        .load_rs2         (load_rs2_array[2]),
        .load_alu         (load_alu_array[2]),
        .load_imm         (load_imm_array[2]),
        .load_flags       (load_flags_array[2]),
        .load_pc_alu      (load_pc_alu_array[2]),
        .sel_pc_next      (sel_pc_next_array[2]),
        .sel_alu_a        (sel_alu_a_array[2]),
        .sel_alu_b        (sel_alu_b_array[2]),
        .sub_sra          (sub_sra_array[2]),
        .load_data_memory (load_data_memory_array[2]),
        .sel_pc_increment (sel_pc_increment_array[2]),
        .sel_pc_jump      (sel_pc_jump_array[2]),
        .sel_mem_next     (sel_mem_next_array[2]),
        .memory_start     (memory_start_array[2]),
        .sel_mem_operation(sel_mem_operation_array[2]),
        .done             (done_array[2])
    );
    fsm_load_store FSM_LOAD_STORE (
        .insn             (insn),
        .code             (code), 
        .start            (start[2]), 
        .clk              (clk), 
        .lu               (lu), 
        .ls               (ls), 
        .eq               (eq),
        .sel_rd           (sel_rd_array[3]),
        .load_pc          (load_pc_array[3]),
        .load_regfile     (load_regfile_array[3]),
        .load_rs1         (load_rs1_array[3]),
        .load_rs2         (load_rs2_array[3]),
        .load_alu         (load_alu_array[3]),
        .load_imm         (load_imm_array[3]),
        .load_flags       (load_flags_array[3]),
        .load_pc_alu      (load_pc_alu_array[3]),
        .sel_pc_next      (sel_pc_next_array[3]),
        .sel_alu_a        (sel_alu_a_array[3]),
        .sel_alu_b        (sel_alu_b_array[3]),
        .sub_sra          (sub_sra_array[3]),
        .load_data_memory (load_data_memory_array[3]),
        .sel_pc_increment (sel_pc_increment_array[3]),
        .sel_pc_jump      (sel_pc_jump_array[3]),
        .sel_mem_next     (sel_mem_next_array[3]),
        .memory_start     (memory_start_array[3]),
        .sel_mem_operation(sel_mem_operation_array[3]),
        .memory_done      (memory_done),
        .done             (done_array[3])
    );
    assign sel_rd_array[0] = 2'b00;
    assign sub_sra_array[0] = 1'b0;
    assign sel_pc_next_array[0] = 1'b0;
    assign sel_alu_a_array[0] = 1'b0;
    assign sel_alu_b_array[0] = 1'b0;
    assign load_pc_alu_array[0] = 1'b0;
    assign load_flags_array[0] = 1'b0;
    assign sel_pc_increment_array[0] = 1'b0;
    assign sel_pc_jump_array[0] = 1'b0;
    assign load_pc_array[0] = 1'b0;
    assign load_regfile_array[0] = 1'b0;
    assign load_rs1_array[0] = 1'b0;
    assign load_rs2_array[0] = 1'b0;
    assign load_alu_array[0] = 1'b0;
    assign load_imm_array[0] = 1'b0;
    assign load_data_memory_array[0] = 1'b0;
    assign memory_start_array[0] = 1'b0;
    assign sel_mem_next_array[0] = 1'b0;
    assign sel_mem_operation_array[0] = 1'b0;
    assign done_array[0] = 1'b0;

    assign sel_rd = sel_rd_array[index];
    assign load_pc = load_pc_array[index];
    assign load_regfile = load_regfile_array[index];
    assign load_rs1 = load_rs1_array[index];
    assign load_rs2 = load_rs2_array[index];
    assign load_alu = load_alu_array[index];
    assign load_imm = load_imm_array[index];
    assign load_flags = load_flags_array[index];
    assign load_pc_alu = load_pc_alu_array[index];
    assign sel_pc_next = sel_pc_next_array[index];
    assign sel_alu_a = sel_alu_a_array[index];
    assign sel_alu_b = sel_alu_b_array[index];
    assign sub_sra = sub_sra_array[index];
    assign load_data_memory = load_data_memory_array[index];
    assign sel_pc_increment = sel_pc_increment_array[index];
    assign sel_pc_jump = sel_pc_jump_array[index];
    assign sel_mem_next = sel_mem_next_array[index];
    assign memory_start = memory_start_array[index];
    assign sel_mem_operation = sel_mem_operation_array[index];
    assign done = done_array[index];

endmodule