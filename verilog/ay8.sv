module NopMachine(IMemory intf);
  parameter HIGH_IMPEDANCE = 1'bZ;

  typedef enum logic [1:0] { ST0, ST1 } stateEnum;
  stateEnum state = ST0;

  logic [7:0] pc = 8'b0000_0000;
  logic [7:0] dummyReg = 8'b0000_0000;

  always_ff @ (posedge intf.CLK, negedge intf.RST) begin
    if (intf.RST == 0) begin
      state <= ST0;
      pc <= 0;
    end
    else begin
      case (state)
        ST0 : begin
                intf.exec(intf.READ, pc);
                state <= ST1;
              end
        ST1 : begin
                pc <= pc + 1;
                state <= ST0;
              end
      endcase
    end
  end

  always_ff @ (posedge intf.CLK, negedge intf.RST) begin
    // このとりこみがuniBusの値反映を待たずに行われているのが問題
    dummyReg <= intf.uniBus;
  end

  assign intf.uniBus = (state == ST1) ? pc : { 8{HIGH_IMPEDANCE} };

endmodule
