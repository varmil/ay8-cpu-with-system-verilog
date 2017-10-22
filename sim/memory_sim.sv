module memory_sim;
  reg CLK, RST;
  wire [7:0] uniBus;

  reg [7:0] adbus_reg;
  reg adbus_active;

  IMemory intf(CLK, RST, uniBus);
  Memory mem(intf);

  always #5 CLK = ~CLK;

  always @ (posedge CLK) begin
    #1 adbus_active = 1'b0;
  end

  assign uniBus = (adbus_active) ? adbus_reg : {8{1'bz}};


  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;

    #5;

    // WRITE
    intf.exec(0, 8'hff);
    #10;
    adbus_reg = 8'haa;
    adbus_active = 1'b1;

    #10;

    // WRITE
    intf.exec(0, 8'hfe);
    #10;
    adbus_reg = 8'hab;
    adbus_active = 1'b1;

    #10;

    // WRITE
    intf.exec(0, 8'hfd);
    #10;
    adbus_reg = 8'hac;
    adbus_active = 1'b1;

    #20;

    // READ
    intf.exec(1, 8'hff);

    #50 $finish;
  end

  initial begin
    $monitor("CLK=%d, RST=%d, intf.isRunning=%d", CLK, RST, intf.isRunning);
  end

endmodule
