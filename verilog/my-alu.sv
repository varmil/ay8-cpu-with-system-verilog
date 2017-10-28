interface IALU();
  logic Mode;
  logic [3:0] Selector;
  logic [7:0] A;
  logic [7:0] B;
  logic CarryIn;

  typedef struct {
    logic [7:0] F;
    logic CarryOut;
    logic ZeroFlag;
  } alu_out;

  alu_out out;

  function void execute(logic ModeArg, logic [3:0] SelectorArg, logic [7:0] AArg, logic [7:0] BArg, logic CarryInArg);
    Mode <= ModeArg;
    Selector <= SelectorArg;
    A <= AArg;
    B <= BArg;
    CarryIn <= CarryInArg;
    // return out;
  endfunction
endinterface

module ALU(IALU intf);
  wire [3:0] notSelector;
  wire cp0, cg0, cp1, cg1;
  wire InternalZeroFlag[1:0];
  wire InternalCarry;

  Circuit74181 alu1(notSelector, intf.A[3:0], intf.B[3:0], intf.Mode, intf.CarryIn, intf.out.F[3:0], cp0, cg0, InternalCarry, InternalZeroFlag[0]);
  Circuit74181 alu2(notSelector, intf.A[7:4], intf.B[7:4], intf.Mode, InternalCarry, intf.out.F[7:4], cp1, cg1, intf.out.CarryOut, InternalZeroFlag[1]);

  assign notSelector = ~intf.Selector;
  or ZFGate(intf.out.ZeroFlag, InternalZeroFlag[0], InternalZeroFlag[1]);

endmodule
