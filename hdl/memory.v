module memory #(
    parameter MemorySize = 256
) (
    input clk,
    input [7:0] data_i,
    input write_mem,
    input [$clog2(MemorySize) - 1:0] addr,
    output [7:0] data_o
);
    reg [7:0] memory [0:MemorySize - 1];

    always @(posedge clk) begin
        if (write_mem) begin
            memory[addr] <= data_i;
        end
    end

    assign data_o = memory[addr];

    initial begin 
        $readmemh({"misc/testes/", "testeInstrucoes/","RAM.hex"}, memory);
    end
    always @(*) begin
        // cada vez que qualquer sinal muda, escreve/sobrescreve um arquivo .hex contendo o conteúdo da memória RAM
        $writememh("RAMOUT.hex", memory);
    end 
endmodule