`timescale  1ns / 100ps

/* TestBench para o comparador de floating point, gera operadores aleatóriamente,
gera o resultado esperado, e compara com o resultado do módulo */

module comparator_fp_tb ();
    
    // Importa funções escritas em C para retornar os valores corretos
    import "DPI-C" function int less_float(int a, int b);
    import "DPI-C" function int greater_float(int a, int b);
    import "DPI-C" function int equal_float(int a, int b);
    import "DPI-C" function int unordered_float(int a, int b);
    import "DPI-C" function longint less_double(longint a, longint b);
    import "DPI-C" function longint greater_double(longint a, longint b);
    import "DPI-C" function longint equal_double(longint a, longint b);
    import "DPI-C" function longint unordered_double(longint a, longint b);

    parameter Size = 64;
    logic [Size - 1: 0] operand_a, operand_b;
    logic less_64, equal_64, greater_64, unordered_64;
    logic less_32, equal_32, greater_32, unordered_32;
    longint less_correct, equal_correct, greater_correct, unordered_correct;
    int errors, i;

    comparator_fp #(.Size(64)) comp64 (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .less(less_64),
        .greater(greater_64),
        .equal(equal_64),
        .unordered(unordered_64)
    );
    comparator_fp #(.Size(32)) comp32 (
        .operand_a(operand_a[31: 0]),
        .operand_b(operand_b[31: 0]),
        .less(less_32),
        .greater(greater_32),
        .equal(equal_32),
        .unordered(unordered_32)
    );

	task display_error;
	begin
    errors += 1;
		$display("--Error--");
		$display("Operand A: %h Operand B: %h", operand_a, operand_b);
		if (Size == 32)
			$display("EQ: %b LESS: %b GREATER: %b UNORDERED: %b", equal_32, less_32, greater_32, unordered_32);
		else 
			$display("EQ: %b LESS: %b GREATER: %b UNORDERED: %b", equal_64, less_64, greater_64, unordered_64);
    $display ("Correct values: EQ: %1b LESS: %1b GREATER: %1b UNORDERED: %1b", equal_correct, less_correct, greater_correct, unordered_correct);
    $display("--------");
	end
    endtask

    initial begin

        /*
        $dumpfile("comparator_fp.vcd");
        $dumpvars(1000, comparator_fp_tb);
        */

        for (i = 0; i < 1_000_000; i++) begin
            operand_a = {$urandom, $urandom};
            operand_b = {$urandom, $urandom};
            less_correct = less_double(operand_a, operand_b);
            greater_correct = greater_double(operand_a, operand_b);
            equal_correct = equal_double(operand_a, operand_b);
            unordered_correct = unordered_double(operand_a, operand_b);
            #1;
            assert (less_correct === less_64 && greater_correct === greater_64 &&
                    equal_correct === equal_64 && unordered_correct === unordered_64)
            else    display_error();
        end

        for (i = 0; i < 1_000_000; i++) begin
            operand_a = {32'b0, $urandom};
            operand_b = {32'b0, $urandom};
            less_correct = less_float(operand_a[31: 0], operand_b[31: 0]);
            greater_correct = greater_float(operand_a[31: 0], operand_b[31: 0]);
            equal_correct = equal_float(operand_a[31: 0], operand_b[31: 0]);
            unordered_correct = unordered_float(operand_a[31: 0], operand_b[31: 0]);
            #1;
            assert (less_correct === less_32 && greater_correct === greater_32 &&
                    equal_correct === equal_32 && unordered_correct === unordered_32)
            else    display_error();
        end

        $display("Got %d errors", errors);
    end


endmodule