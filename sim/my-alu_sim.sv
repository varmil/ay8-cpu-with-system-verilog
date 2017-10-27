module myalu_sim;
  parameter ALU_MODE_LOGICFUNC = 1'b1;
  parameter ALU_MODE_ARITHOP = 1'b0;

  parameter ALU_LOGIC_NOP = 4'h0;
  parameter ALU_LOGIC_AND = 4'h1;
  parameter ALU_LOGIC_OP2 = 4'h2;
  parameter ALU_LOGIC_ALLZERO = 4'h3;
  parameter ALU_LOGIC_OR = 4'h4;
  parameter ALU_LOGIC_SET = 4'h5;
  parameter ALU_LOGIC_XOR = 4'h6;
  parameter ALU_LOGIC_AND_NOT = 4'h7;
  parameter ALU_LOGIC_OP8 = 4'h8;
  parameter ALU_LOGIC_NXOR = 4'h9;
  parameter ALU_LOGIC_SETNOT = 4'ha;
  parameter ALU_LOGIC_NOR = 4'hb;
  parameter ALU_LOGIC_ALLONE = 4'hc;
  parameter ALU_LOGIC_OR_NOT = 4'hd;
  parameter ALU_LOGIC_NAND = 4'he;
  parameter ALU_LOGIC_NOT = 4'hf;

  parameter ALU_ARITH_INC = 4'h0;
  parameter ALU_ARITH_DBL = 4'h3;
  parameter ALU_ARITH_ADD = 4'h6;
  parameter ALU_ARITH_SUB = 4'h9;
  parameter ALU_ARITH_EX = 4'hc;  // extension of carry bit
  parameter ALU_ARITH_DEC = 4'hf;

  parameter ALU_CARRY_ON = 1'b1;
  parameter ALU_CARRY_OFF = 1'b0;
  parameter ALU_BORROW_ON = 1'b0;
  parameter ALU_BORROW_OFF = 1'b1;


  reg CLK, RST;

  reg Mode;
  reg [7:0] Foo;
  reg [3:0] Selector;
  reg [7:0] A, B;
  reg CarryIn;

  reg [7:0] F;
  reg CarryOut;
  reg ZeroFlag;

  ALU ALU(Mode, Selector, A, B, CarryIn, F, CarryOut, ZeroFlag);

  always #5 CLK = ~CLK;

  initial begin
    A = 8'b1111_0001;
    B = 8'b0000_1111;
    Foo = A + B;
    CarryIn = ALU_CARRY_OFF;
  end

  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;

    // 論理演算でCarryフラグ、Zeroフラグが変化するかをみる（=0固定の疑惑あり？）
    // 逆に算術演算の場合、Carryしてたら0、してなかったら1
    // FUNCのときは、CarryIn == CarryOut

    #5; // F = A minus 1 (ARITH)
    A = 8'b1111_1111;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_LOGIC_NOP;
    CarryIn = ALU_CARRY_ON;

    // 25
    #10; // F = A (LOGIC)
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_NOP;
    CarryIn = ALU_CARRY_ON;

    // 35
    #10; // F = A plus B (ARITH) with Carry
    A = 8'b1111_0001;
    B = 8'b0000_1111;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_LOGIC_XOR;
    CarryIn = ALU_CARRY_ON;

    #10; // F = A + B
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_LOGIC_NAND;
    CarryIn = ALU_CARRY_ON;

    // 55
    #10; // F = A + B + 1 のはずが F = A + 1 の予感？
    A = 8'b1111_1111;
    B = 8'b0000_0000;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_LOGIC_NOT;
    CarryIn = ALU_CARRY_OFF;

    #10; // F = 0
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_ALLONE;
    CarryIn = ALU_CARRY_ON;

    #10; // F = 1
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_ALLZERO;
    CarryIn = ALU_CARRY_ON;

    #10; // F = A OR B
    A = 8'b0000_0100;
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_AND;
    CarryIn = ALU_CARRY_ON;



    #50 $finish;
  end

  initial begin
    $monitor("CLK=%d, RST=%d, F=%d", CLK, RST, F);
  end

endmodule
