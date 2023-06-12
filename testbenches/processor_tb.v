`timescale  1ns / 100ps

module processor_tb ();
  wire sel_mem_operation, memory_done, memory_start, write_mem;
  reg reset, clk, start;
  wire [1:0] sel_mem_size;
  wire [2:0] sel_mem_extension;
  wire [7:0] data_mem, mem_o;
  wire [63:0] memory_value, data_o, addr, mem_addr;

  memory_management MM (
    .start            (memory_start), 
    .sel_mem_operation(sel_mem_operation), 
    .clk              (clk),
    .data_i           (data_o),
    .mem_o            (mem_o),
    .addr             (addr),
    .sel_mem_size     (sel_mem_size),
    .done             (memory_done),
    .data_mem         (data_mem),
    .write_mem        (write_mem),
    .mem_addr         (mem_addr),
    .data_o           (memory_value) 
  );

  memory #(.MemorySize(4096)) memory (
    .clk      (clk),
    .data_i   (data_mem),
    .write_mem(write_mem),
    .addr     (mem_addr),
    .data_o   (mem_o)
  );

  processor UUT (
    .clk              (clk),
    .reset            (reset), 
    .sel_mem_operation(sel_mem_operation),
    .sel_mem_size     (sel_mem_size),
    .sel_mem_extension(sel_mem_extension),
    .memory_done      (memory_done),
    .mem_i            (memory_value),
    .start            (start),
    .memory_start     (memory_start),
    .data_o           (data_o),
    .addr             (addr)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0; 
    $dumpfile("processor.vcd");
    $dumpvars(1000, processor_tb);
    reset = 1;
    start = 1;
    #2;
    reset = 0;
    #20;
    start = 0;
    #10000;
    $finish;
  end


endmodule