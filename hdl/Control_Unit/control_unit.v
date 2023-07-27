module control_unit (
    input [31:0] insn,
    input clk, memory_done, start, reset, execute_done,
    output [31:0] code,
    output [4:0] rs1_addr, rs2_addr, rd_addr,
    output [2:0] sel_mem_extension, func3, rounding_mode,
    output reg memory_start, load_ins, start_execute
);
    localparam IDLE = 2'b00;
    localparam FETCH = 2'b01;
    localparam LOAD_IR = 2'b10;
    localparam FSM = 2'b11;

    reg [1:0] state, next;
    
    always @(posedge clk) begin
        state <= next;    
    end

    always @* begin
        case (state)
            IDLE: next = start ? FETCH : IDLE;
            FETCH: next = memory_done ? LOAD_IR : FETCH;
            LOAD_IR: next = FSM;
            FSM: next = execute_done ? FETCH : FSM;
            default next = IDLE;
        endcase
        if (reset) next = IDLE;
    end
    
    always @(state) begin
        memory_start = 1'b0;
        load_ins = 1'b0;
        start_execute = 1'b0;
        case (state)
            FETCH: begin
                memory_start = 1'b1;
            end
            LOAD_IR: begin
                load_ins = 1'b1;
            end
            FSM: begin
                start_execute = 1'b1;
            end
            default: begin
            end
        endcase
    end

    /*  CONSTANT ASSIGNMENTS   */
    assign rs1_addr = insn[19:15];
    assign rs2_addr = insn[24:20];
    assign rd_addr = insn[11:7];
    assign rounding_mode = insn[14:12];
    assign func3 = (code[0] || code[8] || code[5] || code[1] || code[9]) ? 3'b000 : insn[14:12];
    assign sel_mem_extension = insn[14:12];

    /*   OPCDECODER   */
    opdecoder OPDEC (
        .opcode(insn[6:0]),
        .code  (code)
    );

endmodule