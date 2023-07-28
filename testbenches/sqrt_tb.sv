`timescale  1ns / 100ps

module sqrt_tb ();
parameter Size = 64;
logic clk, reset;
logic [Size - 1:0] operand;
logic done;
logic [Size/2 - 1:0] result;
logic [Size/2 - 1:0] correct_result; 
integer errors, i;

	initial
    clk = 1'b1;

	always
    #1 clk = ~clk;

	task display_error;
		begin
			errors += 1;
			$display ("--Error--");
			$display ("operand: %b", operand);
			$display ("Got result: %b", result);
			$display ("Correct result: %b", correct_result);
			$display ("--------");
		end
	endtask

	sqrt #(.Size(Size)) UUT (
		.clk,
		.reset,
		.operand,
		.done,
		.result
	);

	initial begin	
		errors = 0;
		
		for (i = 0; i < 1000; i++) begin
			#2;
			reset = 1; 
			#2;
			reset = 0;
			operand = {$urandom, $urandom};
			correct_result = $floor(operand ** (1/2.0));

			#2;
			while (!done) #2;
			#2
			assert (result === correct_result) else display_error();
		end

		$display("Finished, got %2d errors", errors);
		$finish;
	end

endmodule