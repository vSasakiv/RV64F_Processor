`timescale 1 ns / 100 ps

//Testbench para o decodificador do opcode. Verifica a saída "code" para todos os opcodes possíveis
module opdecoder_tb ();
    reg [6:0]   opcode;
    reg [31:0]  correct_code;
    wire [31:0] code;
    integer     errors;

    task check;
        input [31:0] expected_code;
        if (code !== expected_code) begin 
            $display ("Error, got code: %b, expeted: %b", code, expected_code);
            errors = errors + 1;
        end  
    endtask

    opdecoder UUT (
        .opcode,
        .code
    );

    initial begin
        errors = 0;
       
        opcode = 7'b00_000_11; // Type I (LOAD)
        correct_code = {31'b0, 1'b1};
        #1
        check(correct_code);

        opcode = 7'b00_001_11; // Type I (LOAD-FP)
        correct_code = {30'b0, 1'b1, 1'b0};
        #1
        check(correct_code);
        
        opcode = 7'b00_011_11; // Type I (MISC-MEM)
        correct_code = {28'b0, 1'b1, 3'b0};
        #1
        check(correct_code);

        opcode = 7'b00_100_11; // Type I (OP-IMM)
        correct_code = {27'b0, 1'b1, 4'b0};
        #1
        check(correct_code);

        opcode = 7'b00_101_11; // Type U (AUIPC)
        correct_code = {26'b0, 1'b1, 5'b0};
        #1
        check(correct_code);

        opcode = 7'b00_110_11; // Type I (OP-IMM-32)
        correct_code = {25'b0, 1'b1, 6'b0};
        #1
        check(correct_code);

        opcode = 7'b01_000_11; // Type S (STORE)
        correct_code = {23'b0, 1'b1, 8'b0};
        #1
        check(correct_code);

        opcode = 7'b01_001_11; // Type S (STORE-FP)
        correct_code = {22'b0, 1'b1, 9'b0};
        #1
        check(correct_code);

        opcode = 7'b01_011_11; // Type R (AMO)
        correct_code = {20'b0, 1'b1, 11'b0};
        #1
        check(correct_code);

        opcode = 7'b01_100_11; // Type R (OP)
        correct_code = {19'b0, 1'b1, 12'b0};
        #1
        check(correct_code);

        opcode = 7'b01_101_11; // Type U (LUI)
        correct_code = {18'b0, 1'b1, 13'b0};
        #1
        check(correct_code);

        opcode = 7'b01_110_11; // Type R (OP-32)
        correct_code = {17'b0, 1'b1, 14'b0};
        #1
        check(correct_code);

        opcode = 7'b10_000_11; // Type R4 (MADD)
        correct_code = {15'b0, 1'b1, 16'b0};
        #1
        check(correct_code);

        opcode = 7'b10_001_11; // Type R4 (MSUB)
        correct_code = {14'b0, 1'b1, 17'b0};
        #1
        check(correct_code);

        opcode = 7'b10_010_11; // Type R4 (NMSUB)
        correct_code = {13'b0, 1'b1, 18'b0};
        #1
        check(correct_code);

        opcode = 7'b10_011_11; // Type R4 (NMADD)
        correct_code = {12'b0, 1'b1, 19'b0};
        #1
        check(correct_code);

        opcode = 7'b10_100_11; // Type R (OP-FP)
        correct_code = {11'b0, 1'b1, 20'b0};
        #1
        check(correct_code);

        opcode = 7'b11_000_11; // Type SB (BRANCH)
        correct_code = {7'b0, 1'b1, 24'b0};
        #1
        check(correct_code);

        opcode = 7'b11_001_11; // Type I (JALR)
        correct_code = {6'b0, 1'b1, 25'b0};
        #1
        check(correct_code);

        opcode = 7'b11_011_11; // Type UJ (JAL)
        correct_code = {4'b0, 1'b1, 27'b0};
        #1
        check(correct_code);  

        opcode = 7'b11_100_11; // Type I (SYSTEM)
        correct_code = {3'b0, 1'b1, 28'b0};
        #1
        check(correct_code);

        $display ("Finished, got %2d errors", errors);
        $finish;
    end
    
endmodule