module sqrt_fp_tb ();
parameter Size = 64;
logic clk, reset, start_64, start_32;
logic [Size - 1:0] operand;
logic inexact_32, invalid_32, done_32;
logic inexact_64, invalid_64, done_64;

logic [Size - 1:0] correct_result;
logic [31:0] result_32;
logic [63:0] result_64;

integer errors, precision;

localparam ExpSize = (Size == 64) ? 11 : 8;
localparam MantSize = (Size == 64) ? 52 : 23; 
localparam SqrtSize = (Size == 64) ? 54 : 24;
localparam Bias = (Size == 64) ? 1023 : 127;

	initial
    clk = 1'b1;

	always
    #1 clk = ~clk;

	task display_error;
		begin
			errors += 1;
			$display ("--Error--");
			if (precision == 64) begin
				$display ("operand:        %1b_%11b_%52b", operand[63], operand[62:52], operand[51:0]);
				$display ("Got result:     %1b_%11b_%52b", result_64[63], result_64[62:52], result_64[51:0]);
				$display ("Correct result: %1b_%11b_%52b", correct_result[63], correct_result[62:52], correct_result[51:0]);
			end
			else begin
				$display ("operand:        %1b_%8b_%23b", operand[31], operand[30:23], operand[22:0]);
				$display ("Got result:     %1b_%8b_%23b", result_32[31], result_32[30:23], result_32[22:0]);
				$display ("Correct result: %1b_%8b_%23b", correct_result[31], correct_result[30:23], correct_result[22:0]);
			end
			$display ("--------");
		end
	endtask

	sqrt_fp #(.Size(64)) UUT_64  (
		.clk    (clk),
		.start  (start_64),
		.operand(operand),
		.inexact(inexact_64),
		.invalid(invalid_64),
		.done   (done_64),
		.result (result_64)
	);

	sqrt_fp #(.Size(32)) UUT_32 (
		.clk    (clk),
		.start  (start_32),
		.operand(operand),
		.inexact(inexact_32),
		.invalid(invalid_32),
		.done   (done_32),
		.result (result_32)
	);

	initial begin
		errors = 0;
		start_64 = 1'b0;
		start_32 = 1'b0;
		
///////////////////////////////////////////////Double precision  (Size = 64) /////////////////////////////////////////////////////////
		precision = 64;
		start_64 = 1'b1;
		#2
		operand = 64'h3FF1001000000000; 
		//result      0_01111111111_0000011111100001011100101001100010000010101110111110 =  3FF07E1729882BBE       
		// Test with even exponet
		correct_result = 64'h3FF07E1729882BBE;
		#1;
		while (!done_64) #2;
		#2;
		assert (correct_result === result_64) else display_error();
	

		operand = 64'b0_10000000110_0101001000000000000000000000000000000000000000000000; 
		//Result      0_10000000010_1010000000000000000000000000000000000000000000000000 = 402A000000000000
		//Test with odd exponet
		correct_result = 64'h402A000000000000;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;

		operand = 64'h42BF3C694EEBC000;
		//result      0_10000010101_0110010110110000110011001010101011101000110100111111 = 0x41565B0CCAAE8D3F    
		//Test with rounding    
		correct_result = 64'h41565B0CCAAE8D3F;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;
		operand = 64'h0;
		//result      0_00000000000_0000000000000000000000000000000000000000000000000000 = 0x0    
		//Test with positive zero
		correct_result = 64'h0;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;

		operand = 64'h8000000000000000;
		//result      1_00000000000_0000000000000000000000000000000000000000000000000000 = 0x8000000000000000  
		//Test with negative zero
		correct_result = 64'h8000000000000000;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;

		operand = 64'hFFF1000000000020;
		//result      1_11111111111_1001000000000000000000000000000000000000000000100000 = 0xFFF9000000000020
		//Test NaN
		correct_result = 64'hFFF9000000000020;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;

		operand = 64'hFFF0000000000000;
		//result      1_11111111111_0000000000000000000000000000000000000000000000000000 = 0xFFF0000000000000
		//Test infinity
		correct_result = 64'hFFF0000000000000;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;

		operand = 64'h800001480003840E;
		//result      1_11111111111_1000000000000000000000000000000000000000000000000000 = 0xFFF8000000000000
		//Test negative subnormal 
		correct_result = 64'hFFF8000000000000;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error(); 
		#2;

		operand = 64'h201001480003840E;
		//result      0_01100000000_0000000000001010001111111100101110010110001110011010 = 300000A3FCB9639A
		//Test negative exponet 
		correct_result = 64'h300000A3FCB9639A;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;

		operand = 64'h000201480003840E;
		//result      0_00111111110_0110101001111101110010110000100001011001011010100100 = 1FE6A7DCB08596A4
		//Test subnormal with odd leading zeros 
		correct_result = 64'h1FE6A7DCB08596A4;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		#2;

		operand = 64'h0000000000000420;
		//result  0_00111101011_0000001111111000000111110110001101101011100000001100 = 1EB03F81F636B80C
		//Test subnormal with even leading zeros
		correct_result = 64'h1EB03F81F636B80C;
		#1;
		while (!done_64) #2;
		assert (correct_result === result_64) else display_error();
		$display("Finished double precision, got %2d errors", errors);
		#2;

///////////////////////////////////////////////Single precision  (Size = 32) /////////////////////////////////////////////////////////
		precision = 32;
		start_32 = 1'b1;

		#2
		operand = 32'h3F910208;
		//result  0_01111111_00010000011110100100011 = 3F883D23 
		correct_result = 64'h3F883D23;
		#1;
		while (!done_32) #2;
		assert (correct_result === result_32) else display_error();
		$display("Finished, got %2d errors", errors);
		$finish; 

		operand = 32'hC3290000;
		//Test invalid (negative)
		correct_result = 64'hFFC00000;
		#1;
		while (!done_32) #2;
		assert (correct_result === result_32) else display_error();

		operand = 32'hFFA90200;
		//Test invalid (NaN)
		correct_result = 64'hFFE90200;
		#1;
		while (!done_32) #2;
		assert (correct_result === result_32) else display_error();
		$display("Finished, got %2d errors", errors);
		$finish;

		operand = 32'h80000000;
		//Test zero
		correct_result = 64'h80000000;
		#1;
		while (!done_32) #2;
		assert (correct_result === result_32) else display_error();
		$display("Finished, got %2d errors", errors);
		$finish;

		operand = 32'hFF800000;
		//Test infinity
		correct_result = 64'hFFC00000;
		#1;
		while (!done_32) #2;
		assert (correct_result === result_32) else display_error();
		$display("Finished, got %2d errors", errors);
		$finish;

		operand = 32'h2F880000;
		//Test negative exponent
		correct_result = 64'h3783F07B;
		#1;
		while (!done_32) #2;
		assert (correct_result === result_32) else display_error();
		$display("Finished, got %2d errors", errors);
		$finish;

		operand = 32'h00084000;
		//Test subnormal
		correct_result = 64'h1F01FC10;
		#1;
		while (!done_32) #2;
		assert (correct_result === result_32) else display_error(); 

		$display("Finished single precision, got %2d errors", errors);
		$finish;
	end	

endmodule
