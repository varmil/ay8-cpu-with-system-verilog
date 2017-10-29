module memory_sim;
  reg CLK, RST;
  wire [7:0] uniBus;

  IMemory memIntf(uniBus);
  Memory memory(CLK, RST, memIntf);

  IALU aluIntf();
  ALU alu(aluIntf);

  Core core(CLK, RST, memIntf, aluIntf);

  always #5 CLK = ~CLK;

  initial begin
    // ALL ZERO
    memory.mem[0] = 8'h03;
    // ALL ONE
    memory.mem[1] = 8'h0c;
    // memory.mem[2] = 8'h04;
    // memory.mem[3] = 8'h05;
  end

  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;

    // #100;

    #5;

    // // READ
    // memIntf.takeIn(1, 8'h01);
    core.fetch.execute();
    core.decode_exec.execute();
    //
    #20;

    // // WRITE
    // memIntf.takeIn(0, 8'hff);
    // #10;
    // adbus_reg = 8'haa;
    // adbus_active = 1'b1;
    //
    // #10;
    //
    // // WRITE
    // memIntf.takeIn(0, 8'hfe);
    // #10;
    // adbus_reg = 8'hab;
    // adbus_active = 1'b1;
    //
    // #10;
    //
    // // WRITE
    // memIntf.takeIn(0, 8'hfd);
    // #10;
    // adbus_reg = 8'hac;
    // adbus_active = 1'b1;
    //
    // #20;
    //
    // // READ
    // memIntf.takeIn(1, 8'hff);

    #50 $finish;
  end

  initial begin
    // $monitor("CLK=%d, RST=%d, memIntf.isRunning=%d", CLK, RST, memIntf.isRunning);
  end

endmodule
