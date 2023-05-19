module fsm_alu (
    input [31:0] ins, code,
    input start, clk,
    input lu, ls, eq,
    output [4:0] rs1_addr, rs2_addr, rd_addr,
    output [2:0] sel_mem_extension, func3,
    output [1:0] sel_mem_size, sel_rd,
	output sel_pc_next, sel_pc_alu, sel_alu_a,
    output reg load_pc, load_regfile, load_rs1, load_rs2, load_alu,
    output reg sel_alu_b, sub_sra
);

localparam IDLE = 3'b000;
localparam DECODE = 3'b001;
localparam EXECUTE1 = 3'b010; // Instruções Tipo R alu 64 bits
localparam EXECUTE2 = 3'b011; // Instruções Tipo I alu 64 bits
localparam WRITEBACK = 3'b111;

assign rs1_addr = ins[19:15];
assign rs2_addr = ins[24:20];
assign rd_addr = ins[11:7];
assign func3 = ins[14:12];

assign sel_rd = 2'b00;
assign sel_alu_a = 1'b0;
assign sel_pc_next = 1'b0;
assign sel_pc_alu = 1'b0;
assign sel_mem_extension = ins[14:12];
assign sel_mem_size = ins[13:12];

reg [2:0] state, next;

always @(posedge clk) begin
    state <= next;
end

always @(*) begin
    case (state)
        IDLE: next = (start == 1'b1) ? DECODE : IDLE;
        DECODE: next = (code[12] == 1'b1) ? EXECUTE1 : EXECUTE2; 
        EXECUTE1: next = WRITEBACK;
		EXECUTE2: next = WRITEBACK;
        WRITEBACK: next = IDLE;
        default: next = IDLE;
    endcase
end

always @(posedge clk) begin
    load_pc <= 1'b0;
    load_regfile <= 1'b0;
    load_alu <= 1'b0;
    load_rs1 <= 1'b0;
    load_rs2 <= 1'b0;
    sel_alu_b <= 1'b0;
    sub_sra <= 1'b0;
    case (next)
        IDLE: begin
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            sel_alu_b <= 1'b0;
        end 
        DECODE: begin
            load_rs1 <= 1'b1;
            load_rs2 <= 1'b1;
        end
        EXECUTE1: begin
            load_alu <= 1'b1;
            sub_sra <= ins[30];
            sel_alu_b <= 1'b0;
        end
        EXECUTE2: begin
            load_alu <= 1'b1;
            sub_sra <= (ins[14:12] == 3'b101) ? 1'b1 : 1'b0;
            sel_alu_b <= 1'b1;
        end
        WRITEBACK: begin
            load_pc <= 1'b1;
            load_regfile <= 1'b1;
        end
        default: begin
            load_pc <= 1'b0;
            load_regfile <= 1'b0;
            load_alu <= 1'b0;
            load_rs1 <= 1'b0;
            load_rs2 <= 1'b0;
            sel_alu_b <= 1'b0;
        end 
    endcase
end

endmodule