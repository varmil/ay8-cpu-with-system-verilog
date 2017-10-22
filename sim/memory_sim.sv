module memory_sim;
  reg CLK, RST;
  wire [7:0] uniBus;

  reg [7:0] adbus_reg;
  reg adbus_active;

  IMemory intf(CLK, RST, uniBus);
  Memory memory(intf);
  NopMachine nopMachine(intf);

  always #5 CLK = ~CLK;

  // always @ (posedge CLK) begin
  //   #1 adbus_active = 1'b0;
  // end

  // assign uniBus = (adbus_active) ? adbus_reg : {8{1'bz}};

  initial begin
    memory.mem[0] = 8'h10;
    memory.mem[1] = 8'h11;
    memory.mem[2] = 8'h12;
    memory.mem[3] = 8'h13;
  end

  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;

    #100;

    // #5;

    // // READ
    // intf.exec(1, 8'h01);
    //
    // #20;
    //
    // // WRITE
    // intf.exec(0, 8'hff);
    // #10;
    // adbus_reg = 8'haa;
    // adbus_active = 1'b1;
    //
    // #10;
    //
    // // WRITE
    // intf.exec(0, 8'hfe);
    // #10;
    // adbus_reg = 8'hab;
    // adbus_active = 1'b1;
    //
    // #10;
    //
    // // WRITE
    // intf.exec(0, 8'hfd);
    // #10;
    // adbus_reg = 8'hac;
    // adbus_active = 1'b1;
    //
    // #20;
    //
    // // READ
    // intf.exec(1, 8'hff);

    #50 $finish;
  end

  initial begin
    $monitor("CLK=%d, RST=%d, intf.isRunning=%d", CLK, RST, intf.isRunning);
  end

endmodule
