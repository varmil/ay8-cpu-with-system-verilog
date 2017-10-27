module Core(IMemory intf);
  parameter HIGH_IMPEDANCE = 1'bZ;

  // logic [7:0] pc = 8'b0000_0000;
  // logic [7:0] dummyReg = 8'b0000_0000;

  logic [7:0] pc;
  logic [7:0] dummyReg;

  fetch fetch(intf, pc, dummyReg);

  // enum {
  //   ST0 = 0,
  //   ST1 = 1
  // } state_index_t;
  // logic [3:0] state, next;
  //
  // // Sequential state transition
  // always_ff @(posedge intf.CLK, negedge intf.RST) begin
  //   if (!intf.RST) begin
  //     state       <= '0; // default assignment
  //     state[ST0]  <= 1'b1;
  //   end
  //   else
  //     state       <= next;
  // end
  //
  // // Combinational next state logic
  // always_comb begin
  //   next = '0;
  //   unique case (1'b1)
  //     state[ST0] : next[ST1] = 1'b1;
  //     state[ST1] : next[ST0] = 1'b1;
  //     default    : next[ST0] = 1'b1;
  //   endcase
  // end
  //
  // // Make output assignments
  // always_ff @(posedge intf.CLK, negedge intf.RST) begin
  //   if (!intf.RST) begin
  //     pc <= 0;
  //   end
  //   else begin
  //     unique case (1'b1)
  //       state[ST0] : begin
  //         intf.exec(intf.READ, pc);
  //       end
  //       state[ST1] : begin
  //         pc <= pc + 1;
  //         dummyReg <= intf.uniBus;
  //       end
  //       default: ;
  //     endcase
  //   end
  // end

  // assign intf.uniBus = (state[ST0] == 1'b1) ? pc : { 8{HIGH_IMPEDANCE} };
endmodule

module fetch(IMemory intf, output reg [7:0] pc = 8'b0000_0000, output reg [7:0] dummyReg = 8'b0000_0000);
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
  always_ff @(posedge intf.CLK, negedge intf.RST) begin
    if (!intf.RST) begin
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
      state[ST1]  : next[IDLE] = 1'b1;
    endcase
  end

  // Make output assignments
  always_ff @(posedge intf.CLK, negedge intf.RST) begin
    if (!intf.RST) begin
      pc <= 0;
    end
    else begin
      unique case (1'b1)
        next[ST0] : begin
          intf.exec(intf.READ, pc);
          pc <= pc + 1;
        end
        next[ST1] : begin
          dummyReg <= intf.uniBus;
          trigger <= 0;
        end
        default: ;
      endcase
    end
  end

  assign intf.uniBus = (next[ST0] == 1'b1) ? pc : { 8{HIGH_IMPEDANCE} };
endmodule // fetch