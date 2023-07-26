module memory_management (
    input start, sel_mem_operation, clk,
    input [63:0] data_i,
    input [7:0] mem_o,
    input [63:0] addr,
    input [1:0] sel_mem_size,
    output reg done, write_mem,
    output reg [7:0] data_mem,
    output reg [63:0] mem_addr,
    output [63:0] data_o 
);
    localparam IDLE = 3'b001;
    localparam ADDR = 3'b010;
    localparam EXECUTE_LOAD = 3'b011;
    localparam EXECUTE_STORE = 3'b101;
    localparam RETURN = 3'b110;

    wire [3:0] size;
    reg [3:0] counter;
    reg [2:0] state, next;
    reg [7:0] data_load [0:7];
    wire [7:0] data_store [0:7];
    wire[63:0] teste;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : nets
            assign data_store[i] = data_i[8 * i + 7: 8 * i];
        end
    endgenerate

    decoder #(2) dec2to4_size (.data_i(sel_mem_size), .data_o(size));

    assign data_o = {data_load[7], data_load[6],  data_load[5],  data_load[4],  data_load[3],  data_load[2],  data_load[1],  data_load[0]};

    always @(posedge clk) begin
        state <= next; // atualiza o estado a cada ciclo de clock 
    end

    always @(*) begin
        case (state)
            IDLE: next = (start == 1'b1) ?  ADDR : IDLE;
            ADDR: next = (sel_mem_operation == 1'b1) ? EXECUTE_STORE : EXECUTE_LOAD;
            EXECUTE_STORE: next = (size == counter) ? RETURN : EXECUTE_STORE; 
            EXECUTE_LOAD: next = (size == counter) ? RETURN : EXECUTE_LOAD;
            RETURN: next = IDLE;
            default: next = IDLE;
        endcase
    end

    always @(posedge clk) begin
        // inicializamos alguns valores toda vez que temos subida 
        done <= 1'b0;
        counter <= 4'b0;
		mem_addr <= 64'b0;
        write_mem <= 1'b0;
        case (next)
            ADDR: mem_addr <= addr;
            EXECUTE_STORE: begin
                write_mem <= 1'b1; 
                data_mem <= data_store[counter[2:0]];
                mem_addr <= mem_addr + {63'b0, write_mem};
                counter <= counter + 4'b0001;
            end
            EXECUTE_LOAD: begin
                data_load[counter[2:0]] <= mem_o;
                mem_addr <= mem_addr + 1;
                counter <= counter + 4'b0001;
            end
            RETURN: begin
                done <= 1'b1; 
            end
            default: begin
                done <= 1'b0;
                counter <= 4'b0;
                mem_addr <= addr;
                write_mem <= 1'b0;
            end 
        endcase
    end

endmodule