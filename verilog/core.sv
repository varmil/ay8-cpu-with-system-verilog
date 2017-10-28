interface ICore();
  parameter HIGH_IMPEDANCE = 1'bZ;

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

  logic [7:0] pc     = 8'b0000_0000;
  logic [7:0] buffer = 8'b0000_0000;
  logic [7:0] acc    = 8'b0000_0000;
  logic [7:0] ir     = 8'b0000_0000;
  logic  CarryReg    = HIGH_IMPEDANCE;
  logic  ZFReg       = HIGH_IMPEDANCE;

endinterface

// boot後の最初の2サイクルはbufferの初期値、つまりNOPを実行する。その後pcゼロ番地の命令へ。
module Core(input logic CLK, input logic RST, IMemory memIntf, IALU aluIntf);
  ICore coreIntf();

  fetch fetch(CLK, RST, memIntf, coreIntf, aluIntf);
  decode_exec decode_exec(CLK, RST, memIntf, coreIntf, aluIntf);
endmodule




module fetch(logic CLK, logic RST, IMemory memIntf, ICore coreIntf, IALU aluIntf);
  parameter HIGH_IMPEDANCE = 1'bZ;

  logic trigger;

  enum {
    IDLE = 0,
    ST0  = 1,
    ST1  = 2
  } state_index_t;
  logic [3:0] state, next;

  function void execute();
    trigger <= 1'b1;
  endfunction

  // Sequential state transition
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
      state       <= '0; // default assignment
      state[IDLE] <= 1'b1;
    end
    else
      state       <= next;
  end

  // Combinational next state logic
  always_comb begin
    next = '0;
    unique case (1'b1)
      state[IDLE] : begin
        if (trigger) next[ST0] = 1'b1;
        else next[IDLE] = 1'b1;
      end
      state[ST0]  : next[ST1]  = 1'b1;
      state[ST1]  : begin
        if (trigger) next[ST0] = 1'b1;
        else next[IDLE] = 1'b1;
      end
      default: next[IDLE] = 1'b1;
    endcase
  end

  // Make output assignments
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
      coreIntf.pc <= 0;
    end
    else begin
      unique case (1'b1)
        next[ST0] : begin
          memIntf.takeIn(memIntf.READ, coreIntf.pc);
          aluIntf.execute(coreIntf.ALU_MODE_ARITHOP, coreIntf.ALU_ARITH_INC, coreIntf.pc, coreIntf.buffer, coreIntf.ALU_CARRY_LOW);
          // coreIntf.pc <= coreIntf.pc + 1;
          trigger <= 0;
        end
        next[ST1] : begin
          coreIntf.buffer <= memIntf.uniBus;
        end
        default: ;
      endcase
    end
  end

  // Assign ALU output to each register here
  always_comb begin
    if (state[ST0] == 1'b1 && aluIntf.A == coreIntf.pc)
      coreIntf.pc = aluIntf.out.F;
  end

  assign memIntf.uniBus = (next[ST0] == 1'b1) ? coreIntf.pc : { 8{HIGH_IMPEDANCE} };
endmodule // fetch




module decode_exec(logic CLK, logic RST, IMemory memIntf, ICore coreIntf, IALU aluIntf);
  parameter HIGH_IMPEDANCE = 1'bZ;

  logic trigger;

  enum {
    IDLE            = 0,
    DECODE          = 1,
    EX_LOGIC_0      = 2,
    EX_LOGIC_IMM    = 3,
    EX_LOGIC_WAIT   = 4,
    EX_DO_LOGIC     = 5,
    EX_LOGIC_REF    = 6,
    EX_LOGIC_REF_1  = 7,
    EX_LOGIC_REF_2  = 8
  } state_index_t;
  logic [3:0] state, current;

  function void execute();
    state <= DECODE;
  endfunction

  // Sequential state transition
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
      state       <= IDLE; // default assignment
    end
    else
      current     <= state;
  end

  // Make output assignments
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
    end
    else begin
      unique case (state)
        DECODE : begin
          // cache instruction
          coreIntf.ir <= coreIntf.buffer;

          // decode
          case (coreIntf.buffer[7:4])
            // 1byte ir or ref imm ir (2bytes)
            4'h0: begin
              if (coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_NOP ||
                  coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_ALLZERO ||
                  coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_ALLONE ||
                  coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_NOT)
                    state <= EX_LOGIC_0;
              else  state <= EX_LOGIC_IMM;
            end
            // ref address ir (2bytes)
            4'h1: begin
              state <= EX_LOGIC_REF;
            end
            // undef
            default: begin
              state <= EX_LOGIC_0;
            end
          endcase
        end // DECODE

        EX_LOGIC_0: begin
          aluIntf.execute(coreIntf.ALU_MODE_LOGICFUNC, coreIntf.ir[3:0], coreIntf.acc, coreIntf.buffer, coreIntf.ALU_CARRY_HIGH);
          state
        end // EX_LOGIC_0

        default: ;
      endcase
    end
  end

  // Assign ALU output to each register here
  always_comb begin
    if (current == EX_LOGIC_0)
      coreIntf.acc = aluIntf.out.F;
      if (coreIntf.ir[3:0] != ALU_LOGIC_NOP) coreIntf.ZFReg = aluIntf.out.ZeroFlag;
  end

endmodule // decode_exec
