interface ICore();
  parameter HIGH_IMPEDANCE = 1'bZ;

  logic [7:0] pc = 8'b0000_0000;
  logic [7:0] dummyReg = 8'b0000_0000;

  function void takeIn();
  endfunction
endinterface

module Core(input logic CLK, input logic RST, IMemory memIntf);
  ICore coreIntf();
  fetch fetch(CLK, RST, memIntf, coreIntf);
endmodule




module fetch(logic CLK, logic RST, IMemory memIntf, ICore coreIntf);
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
          coreIntf.pc <= coreIntf.pc + 1;
          trigger <= 0;
        end
        next[ST1] : begin
          coreIntf.dummyReg <= memIntf.uniBus;
        end
        default: ;
      endcase
    end
  end

  assign memIntf.uniBus = (next[ST0] == 1'b1) ? coreIntf.pc : { 8{HIGH_IMPEDANCE} };
endmodule // fetch




module decode_exec(logic CLK, logic RST, IMemory memIntf, ICore coreIntf);

endmodule // decode_exec
