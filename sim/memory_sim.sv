module memory_sim;
  reg CLK, RST;

  IMemory intf(CLK, RST);
  Memory mem(intf);

  always #5 CLK = ~CLK;

  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;
    #55  intf.exec(0, 8'hff);
    #10  intf.adbus <= 8'h11;
    #20  intf.exec(1, 8'hff);
    #150 $finish;
  end

  initial begin
    $monitor("CLK=%d, RST=%d, intf.isRunning=%d", CLK, RST, intf.isRunning);
  end

endmodule
