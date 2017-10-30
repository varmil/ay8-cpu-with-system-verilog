// a = 8'h03, b = 8'h06

// 0503 //A←0b0011
// 0106 //A←A OR 0b0110
//
// 0503 //A←0b0011
// 0206 //A←A OR (NOT0b0110) == 0000_0011 OR 1111_1001 == 1111_1011
//
// 0503 //A←0b0011
// 03   //A←0xff
// 00   // NOP (タイミング調整のため)
//
// 0503 //A←0b0011
// 0406 //A←A AND 0b0110
//
// 0503 //A←0b0011
// 0506 //A←0b0110
//
// 0503 //A←0b0011
// 0606 //A← NOT (A XOR 0b0110)
//
// 0503 //A←0b0011
// 0706 //A←(NOTA) OR 0b0110
//
// 0503 //A←0b0011
// 0806 //A←A AND (NOT0b0110)
//
// 0503 //A←0b0011
// 0906 //A←A XOR 0b0110
//
// 0503 //A←0b0011
// 0a06 //A←NOT 0b0110
//
// 0503 //A←0b0011
// 0b06 //A←NOT(A AND 0b0110)
//
// 0503 //A←0b0011
// 0c   //A←0x00
// 00   // NOP
//
// 0503 //A←0b0011h
// 0d06 //A←(NOTA) AND 0b0110
//
// 0503 //A←0b0011
// 0e06 //2A←NOT(A OR 0b0110)
//
// 0503 //A←0b0011
// 0f06 //A←NOT A
//
// 00 // NOP
// 00 // ウメクサ
// 00
// 00



module logic_ir_sim;
  reg CLK, RST;
  wire [7:0] uniBus;

  logic [7:0] testData [0:63] = '{
    8'h05,
    8'h03,
    8'h01,
    8'h06,

    8'h05,
    8'h03,
    8'h02,
    8'h06,

    8'h05,
    8'h03,
    8'h03,
    8'h00,

    8'h05,
    8'h03,
    8'h04,
    8'h06,

    8'h05,
    8'h03,
    8'h05,
    8'h06,

    8'h05,
    8'h03,
    8'h06,
    8'h06,

    8'h05,
    8'h03,
    8'h07,
    8'h06,

    8'h05,
    8'h03,
    8'h08,
    8'h06,

    8'h05,
    8'h03,
    8'h09,
    8'h06,

    8'h05,
    8'h03,
    8'h0a,
    8'h06,

    8'h05,
    8'h03,
    8'h0b,
    8'h06,

    8'h05,
    8'h03,
    8'h0c,
    8'h00,

    8'h05,
    8'h03,
    8'h0d,
    8'h06,

    8'h05,
    8'h03,
    8'h0e,
    8'h06,

    8'h05,
    8'h03,
    8'h0f,
    8'h06,

    8'h00,
    8'h00,
    8'h00,
    8'h00
  };

  IMemory memIntf(uniBus);
  Memory memory(CLK, RST, memIntf);

  IALU aluIntf();
  ALU alu(aluIntf);

  Core core(CLK, RST, memIntf, aluIntf);

  always #5 CLK = ~CLK;

  initial begin
    for(int i=0; i<64; i++) begin
      memory.mem[i] = testData[i];
    end
  end

  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;

    #5;

    // 15: start
    // 25 - 45: first nop
    // 75 - 115: the first result on acc
    // 115 - 155; the second result on acc

    #103;

    // 118
    for (int i=0; i<15; i++) begin
      $write(" %x", core.coreIntf.acc);
      #80;
    end
    $display("");

    #10 $finish;
  end

  initial begin
    // $monitor("CLK=%d, RST=%d, memIntf.isRunning=%d", CLK, RST, memIntf.isRunning);
  end

endmodule
