`timescale 1 ns / 100 ps

module cpu_tb ();
  reg reset;

  cpu processor (
      .reset
  );

  //Testa uma instrução de load e uma de store. Gera uma waveform, a qual deve ser analisada
  initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(1000, cpu_tb);
    reset = 1;
    #2;
    reset = 0;
    #5000;
    $finish;
  end

endmodule