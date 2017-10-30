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

  // trigger
  logic fetchTrigger = 0;
  logic decodeTrigger = 0;
  function void do_decode_fetch();
    invoke_fetch();
    invoke_decode();
  endfunction
  function void invoke_fetch();
    fetchTrigger <= 1'b1;
  endfunction
  function void invoke_decode();
    decodeTrigger <= 1'b1;
  endfunction


endinterface

// boot後の最初の2サイクルはbufferの初期値、つまりNOPを実行する。その後pcゼロ番地の命令へ。
module Core(input logic CLK, input logic RST, IMemory memIntf, IALU aluIntf);
  ICore coreIntf();
  fetch fetch(CLK, RST, memIntf, coreIntf, aluIntf);
  decode_exec decode_exec(CLK, RST, memIntf, coreIntf, aluIntf);
endmodule




module fetch(logic CLK, logic RST, IMemory memIntf, ICore coreIntf, IALU aluIntf);
  parameter HIGH_IMPEDANCE = 1'bZ;
  parameter STATE_ENABLE = 1'b1;

  enum {
    IDLE = 0,
    ST0  = 1,
    ST1  = 2
  } state_index_t;
  logic [3:0] state, next;

  function void execute();
    coreIntf.fetchTrigger <= STATE_ENABLE;
  endfunction

  // IDLEへ戻るか、FETCHへ遷移するかを決める
  function void toIdleIfNotTriggered();
    if (coreIntf.fetchTrigger) next[ST0] = STATE_ENABLE;
    else next[IDLE] = STATE_ENABLE;
  endfunction

  // Sequential state transition
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
      state       <= '0; // default assignment
      state[IDLE] <= STATE_ENABLE;
    end
    else
      state <= next;
  end

  // Combinational next state logic
  always_comb begin
    next = '0;
    unique case (STATE_ENABLE)
      state[IDLE] : toIdleIfNotTriggered();
      state[ST0]  : next[ST1]  = STATE_ENABLE;
      state[ST1]  : toIdleIfNotTriggered();
      default     : next[IDLE] = STATE_ENABLE;
    endcase
  end

  // Make output assignments
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
      coreIntf.pc <= 0;
    end
    else begin
      unique case (STATE_ENABLE)
        // take in PC and output mem data to uniBus, and then PC++ with ALU
        next[ST0] : begin
          memIntf.takeIn(memIntf.READ, coreIntf.pc);
          aluIntf.execute(coreIntf.ALU_MODE_ARITHOP, coreIntf.ALU_ARITH_INC, coreIntf.pc, coreIntf.buffer, coreIntf.ALU_CARRY_LOW);
          // coreIntf.pc <= coreIntf.pc + 1;
        end

        // mem data --> buffer
        next[ST1] : begin
          coreIntf.buffer <= memIntf.uniBus;
        end

        default: ;
      endcase
    end
  end

  always_ff @(posedge CLK, negedge RST) begin
    if (coreIntf.fetchTrigger) coreIntf.fetchTrigger <= 0;
  end

  // Assign ALU output to each register here
  always_comb begin
    if (state[ST0] == STATE_ENABLE && aluIntf.A == coreIntf.pc)
      coreIntf.pc = aluIntf.out.F;
  end

  assign memIntf.uniBus = (next[ST0] == STATE_ENABLE) ? coreIntf.pc : { 8{HIGH_IMPEDANCE} };
endmodule // fetch




module decode_exec(logic CLK, logic RST, IMemory memIntf, ICore coreIntf, IALU aluIntf);
  parameter HIGH_IMPEDANCE = 1'bZ;
  parameter STATE_ENABLE = 1'b1;

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
  logic [9:0] state, next;

  function void execute();
    coreIntf.decodeTrigger <= STATE_ENABLE;
  endfunction

  // IDLEへ戻るか、DECODEへ遷移するかを決める
  function void toIdleIfNotTriggered(logic triggerState);
    if (coreIntf.decodeTrigger) next[triggerState] = STATE_ENABLE;
    else next[IDLE] = STATE_ENABLE;
  endfunction

  // Sequential state transition
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
      state       <= '0; // default assignment
      state[IDLE] <= STATE_ENABLE;
    end
    else
      state <= next;
  end

  // Combinational next state logic
  always_comb begin
    next = '0;
    unique case (STATE_ENABLE)
      state[IDLE] : begin
        toIdleIfNotTriggered(DECODE);
      end

      state[DECODE] : begin
        // cache instruction
        coreIntf.ir = coreIntf.buffer;

        case (coreIntf.buffer[7:4])
          // 1byte ir or ref imm ir (2bytes)
          4'h0: begin
            if (coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_NOP ||
                coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_ALLZERO ||
                coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_ALLONE ||
                coreIntf.buffer[3:0] == coreIntf.ALU_LOGIC_NOT)
                  next[EX_LOGIC_0] = STATE_ENABLE;
            else  next[EX_LOGIC_IMM] = STATE_ENABLE;
          end
          // ref address ir (2bytes)
          4'h1: begin
            next[EX_LOGIC_REF] = STATE_ENABLE;
          end
          // undef
          default: begin
            next[EX_LOGIC_0] = STATE_ENABLE;
          end
        endcase
      end // DECODE

      state[EX_LOGIC_0]: begin
        toIdleIfNotTriggered(DECODE);
      end // EX_LOGIC_0

      state[EX_LOGIC_IMM]: begin
        next[EX_LOGIC_WAIT] = STATE_ENABLE;
      end // EX_LOGIC_IMM

      state[EX_LOGIC_WAIT]: begin
        // ALU is using by fetch for invrement PC
        next[EX_DO_LOGIC] = STATE_ENABLE;
      end // EX_LOGIC_WAIT

      state[EX_DO_LOGIC]: begin
        toIdleIfNotTriggered(DECODE);
      end // EX_DO_LOGIC

      default: next[IDLE] = STATE_ENABLE;
    endcase
  end

  // Make output assignments
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
    end
    else begin
      unique case (STATE_ENABLE)
        next[EX_LOGIC_0] : begin
          aluIntf.execute(coreIntf.ALU_MODE_LOGICFUNC, coreIntf.ir[3:0], coreIntf.acc, coreIntf.buffer, coreIntf.ALU_CARRY_HIGH);
          coreIntf.do_decode_fetch();
        end

        next[EX_LOGIC_IMM] : begin
          coreIntf.invoke_fetch();
        end

        next[EX_DO_LOGIC] : begin
          aluIntf.execute(coreIntf.ALU_MODE_LOGICFUNC, coreIntf.ir[3:0], coreIntf.acc, coreIntf.buffer, coreIntf.ALU_CARRY_HIGH);
          coreIntf.do_decode_fetch();
        end

        default: ;
      endcase
    end
  end

  always_ff @(posedge CLK, negedge RST) begin
    if (coreIntf.decodeTrigger) coreIntf.decodeTrigger <= 0;
  end

  // Assign ALU output to each register here
  always_comb begin
    if (state[EX_LOGIC_0] == STATE_ENABLE) begin
      coreIntf.acc = aluIntf.out.F;
      if (coreIntf.ir[3:0] != coreIntf.ALU_LOGIC_NOP) coreIntf.ZFReg = aluIntf.out.ZeroFlag;
    end

    if (state[EX_DO_LOGIC] == STATE_ENABLE) begin
      coreIntf.acc = aluIntf.out.F;
      coreIntf.ZFReg = aluIntf.out.ZeroFlag;
    end
  end

endmodule // decode_exec
