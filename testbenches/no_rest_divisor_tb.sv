`timescale  1ns / 100ps

module no_rest_divisor_tb();
    parameter Size = 64;
    logic unsigned [63:0] divisor, dividend, quotient, remainder;
    logic done, start, clk;
    int errors, i;

initial
    clk = 1'b1;

always
    #1 clk = ~clk;

task display_error;
    errors += 1;
    $display("Divisor: %h, Dividend: %h, Quotient: %h, Remainder: %h", divisor, dividend, quotient, remainder);
endtask

no_rest_divisor no_rest_divisor (
    .clk (clk),
    .start(start),
    .divisor(divisor),
    .dividend(dividend),
    .quotient(quotient),
    .remainder(remainder),
    .done(done)
);

initial begin
    errors = 0;
    #2
    $dumpfile("no_rest_divisor.vcd");
    $dumpvars(100, no_rest_divisor_tb);

    for (i = 0; i < 1000; i++) begin
        start = 1;
        divisor = {$urandom, $urandom};
        dividend = {$urandom, $urandom};
        #2;
        while (!done) #1;
        assert (quotient === (dividend / divisor) && remainder === (dividend % divisor)) else display_error();
        start = 0;
        #10;
    end
	$display("Finished, got %2d errors", errors);
    $finish;
end


endmodule