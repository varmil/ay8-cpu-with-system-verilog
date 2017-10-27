module myalu_sim;
  parameter ALU_MODE_LOGICFUNC = 1'b1;
  parameter ALU_MODE_ARITHOP = 1'b0;

  parameter ALU_LOGIC_NOP = 4'h0;
  parameter ALU_LOGIC_OR = 4'h1;
  parameter ALU_LOGIC_OR_NOT = 4'h2;
  parameter ALU_LOGIC_ALLONE = 4'h3;
  parameter ALU_LOGIC_AND = 4'h4;
  parameter ALU_LOGIC_SET = 4'h5;
  parameter ALU_LOGIC_NXOR = 4'h6;
  parameter ALU_LOGIC_NOT_A_OR = 4'h7;
  parameter ALU_LOGIC_AND_NOT = 4'h8;
  parameter ALU_LOGIC_XOR = 4'h9;
  parameter ALU_LOGIC_SETNOT = 4'ha;
  parameter ALU_LOGIC_NAND = 4'hb;
  parameter ALU_LOGIC_ALLZERO = 4'hc;
  parameter ALU_LOGIC_NOT_A_AND = 4'hd;
  parameter ALU_LOGIC_NOR = 4'he;
  parameter ALU_LOGIC_NOT = 4'hf;

  parameter ALU_ARITH_INC = 4'hf;  // if carry flag is on (Cn = L)
  parameter ALU_ARITH_DBL = 4'h3;  // Double A
  parameter ALU_ARITH_ADD = 4'h6;
  parameter ALU_ARITH_SUB = 4'h9;
  parameter ALU_ARITH_EX  = 4'hc;  // extension of carry bit
  parameter ALU_ARITH_DEC = 4'h0;  // if bollow flag is on (Cn = H)

  parameter ALU_CARRY_HIGH = 1'b1;
  parameter ALU_CARRY_LOW = 1'b0;
  parameter ALU_BORROW_LOW = 1'b0;
  parameter ALU_BORROW_HIGH = 1'b1;


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
    CarryIn = ALU_CARRY_LOW;
  end

  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;

    // 論理演算ではZeroフラグのみ変化
    // 算術演算では、加えてCarryフラグも変化
    // 両フラグともActive Low

    #5; // F = A minus 1 (ARITH)
    A = 8'b0000_0000;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_ARITH_DEC;
    CarryIn = ALU_CARRY_HIGH;

    // 25
    #10; // F = A AND B
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_AND;

    #10; // F = A XOR B
    A = 8'b0010_0001;
    B = 8'b0000_1111;
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_XOR;

    #10; // F = A plus B (-> carry)
    A = 8'b1111_0001;
    B = 8'b0000_1111;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_ARITH_ADD;
    CarryIn = ALU_CARRY_LOW;

    // 55
    #10; // F = A plus 1
    A = 8'b1111_1110;
    B = 8'b0000_0000;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_ARITH_INC;
    CarryIn = ALU_CARRY_LOW;

    #10; // F = A minus B
    A = 8'b0001_0000;
    B = 8'b0000_0001;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_ARITH_SUB;
    CarryIn = ALU_CARRY_LOW;

    #10; // F = A minus B (-> bollow)
    A = 8'b0000_0001;
    B = 8'b0000_0011;
    Mode = ALU_MODE_ARITHOP;
    Selector = ALU_ARITH_SUB;
    CarryIn = ALU_CARRY_LOW;

    #10; // F = 0
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_ALLZERO;

    #10; // F = 1
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_ALLONE;

    // 105
    #10; // F = A OR B
    A = 8'b0000_0100;
    B = 8'b1111_0100;
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_OR;

    #10; // F = A
    A = 8'b0001_0001;
    Mode = ALU_MODE_LOGICFUNC;
    Selector = ALU_LOGIC_NOP;
    CarryIn = ALU_CARRY_HIGH;


    #20 $finish;
  end

  initial begin
    $monitor("CLK=%d, RST=%d, F=%d", CLK, RST, F);
  end

endmodule
