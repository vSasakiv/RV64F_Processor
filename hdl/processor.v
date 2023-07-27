module processor (
    input reset, start,
    input memory_done, //Retorna se acabou a operação da FSM do memory_management
    input clk,
    input [63:0] mem_i, //Valor carregado da memória 
    output sel_mem_operation, //Seleciona, no memory_management, entre load (se = 0) e store (se = 1)
    output [1:0] sel_mem_size, 
    output [2:0] sel_mem_extension,
    output memory_start, //inicia FSM do memory_management
    output [63:0] data_o, //Saída que vai para entrada de dados da memória
    output [63:0] addr //Endereço a ser lido/gravado na memória
);
    wire sel_pc_next, sel_pc_alu, sel_alu_a, sel_alu_b, sel_alu_32b, sub_sra;
    wire load_data_memory, load_pc_alu, load_flags, load_pc, load_ins, load_regfile, load_rs1, load_rs2, load_alu, load_imm;
    wire load_rs1_fp, load_rs2_fp, load_regfile_fp, sel_store_fp, sel_rd_fp, load_alu_fp, start_add_sub_fp, start_mult_fp, sub_fp;
    wire sel_pc_increment, sel_pc_jump, done_fp;
    wire start_execute, execute_done;
    wire memory_start_cu, memory_start_fsm;
    wire [1:0] sel_rd;
    wire [2:0] flags_value, func3, rounding_mode;
    wire [31:0] insn, code;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;

    //***Sinais novos q saem da CU
    wire sel_mem_next; //Seleciona se o próximo endereço da memória é alu_value ou pc_value

    //***Outros sinais
    wire [7:0] mem_o; //Saída da memória
    wire [7:0] data_mem; //Entrada da memória
    wire [63:0] mem_addr; // Endereço da memória

    assign memory_start = memory_start_cu | memory_start_fsm;

    control_unit CU (
        .clk              (clk),
        .insn             (insn),
        .memory_done      (memory_done),
        .code             (code),
        .start            (start),
        .reset            (reset),
        .execute_done     (execute_done),
        .rs1_addr         (rs1_addr),
        .rs2_addr         (rs2_addr),
        .rd_addr          (rd_addr),
        .sel_mem_extension(sel_mem_extension),
        .func3            (func3),
        .rounding_mode    (rounding_mode),
        .memory_start     (memory_start_cu),
        .load_ins         (load_ins),
        .start_execute    (start_execute)
    );

    execute_fsm FSM (
        .code             (code),
        .insn             (insn),
        .start            (start_execute),
        .clk              (clk),
        .memory_done      (memory_done),
        .done_fp          (done_fp),
        .lu               (flags_value[2]),
        .ls               (flags_value[1]),
        .eq               (flags_value[0]),
        .sel_rd           (sel_rd),
        .sub_sra          (sub_sra),
        .sel_pc_nexta     (sel_pc_next),
        .sel_alu_a        (sel_alu_a),
        .sel_alu_b        (sel_alu_b),
        .load_pc_alu      (load_pc_alu),
        .load_flags       (load_flags),
        .sel_pc_increment (sel_pc_increment),
        .sel_pc_jump      (sel_pc_jump),
        .sel_alu_32b      (sel_alu_32b),
        .load_pc          (load_pc),
        .load_regfile     (load_regfile),
        .load_alu         (load_alu),
        .load_reg         (load_reg),
        .load_regfile_fp  (load_regfile_fp),
        .sel_store_fp     (sel_store_fp),
        .sel_rd_fp        (sel_rd_fp),
        .start_add_sub_fp (start_add_sub_fp),
        .start_mult_fp    (start_mult_fp),
        .load_alu_fp      (load_alu_fp),
        .sub_fp           (sub_fp),
        .load_data_memory (load_data_memory),
        .memory_start     (memory_start_fsm),
        .sel_mem_next     (sel_mem_next),
        .sel_mem_operation(sel_mem_operation),
        .done             (execute_done)
    );

    dataflow DP (
        .clk              (clk),
        .sub_sra          (sub_sra),
        .done_fp          (done_fp),
        .reset            (reset),
        .sel_pc_next      (sel_pc_next),
        .sel_pc_increment (sel_pc_increment),
        .sel_pc_jump      (sel_pc_jump), 
        .sel_alu_a        (sel_alu_a), 
        .sel_alu_b        (sel_alu_b),
        .sel_alu_32b      (sel_alu_32b),
        .load_ins         (load_ins), 
        .load_reg         (load_reg),
        .load_regfile     (load_regfile), 
        .load_pc          (load_pc), 
        .load_alu         (load_alu), 
        .load_flags       (load_flags),
        .load_pc_alu      (load_pc_alu), 
        .load_data_memory (load_data_memory),
        .sel_rd           (sel_rd),
        .rounding_mode    (rounding_mode), 
        .func3            (func3),
        .sel_mem_extension(sel_mem_extension),
        .rd_addr          (rd_addr), 
        .rs1_addr         (rs1_addr), 
        .rs2_addr         (rs2_addr),
        .code             (code),
        .insn             (insn),
        .sel_mem_next     (sel_mem_next),
        .mem_i            (mem_i),
        .flags_value      (flags_value),
        .store_value_o    (data_o),
        .addr             (addr),
        .load_regfile_fp  (load_regfile_fp),
        .sel_store_fp     (sel_store_fp),
        .sel_rd_fp        (sel_rd_fp),
        .load_alu_fp      (load_alu_fp),
        .start_add_sub_fp (start_add_sub_fp),
        .start_mult_fp    (start_mult_fp),
        .sub_fp           (sub_fp)
    );

endmodule