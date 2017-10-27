module ALU(Mode, Selector, A, B, CarryIn, F, CarryOut, ZeroFlag);
  input logic Mode;
  input logic [3:0] Selector;
  input logic [7:0] A, B;
  input logic CarryIn;

  output logic [7:0] F;
  output logic CarryOut;
  output logic ZeroFlag;

  wire [3:0] notSelector;
  wire cp0, cg0, cp1, cg1;
  wire InternalCarry, InternalZeroFlag0, InternalZeroFlag1;

  Circuit74181 alu1(notSelector, A[3:0], B[3:0], Mode, CarryIn, F[3:0], cp0, cg0, InternalCarry, InternalZeroFlag0);
  Circuit74181 alu2(notSelector, A[7:4], B[7:4], Mode, InternalCarry, F[7:4], cp1, cg1, CarryOut, InternalZeroFlag1);

  assign notSelector = ~Selector;

  assign ZeroFlag = InternalZeroFlag0 & InternalZeroFlag1;

endmodule
