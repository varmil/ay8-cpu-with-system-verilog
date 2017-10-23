module NopMachine(IMemory intf);
  parameter HIGH_IMPEDANCE = 1'bZ;

  // typedef enum logic [1:0] { ST0, ST1 } stateEnum;
  // stateEnum state = ST0;

  logic [7:0] pc = 8'b0000_0000;
  logic [7:0] dummyReg = 8'b0000_0000;

  // always_ff @ (posedge intf.CLK, negedge intf.RST) begin
  //   if (intf.RST == 0) begin
  //     state <= ST0;
  //     pc <= 0;
  //   end
  //   else begin
  //     case (state)
  //       ST0 : begin
  //               intf.exec(intf.READ, pc);
  //               state <= ST1;
  //             end
  //       ST1 : begin
  //               pc <= pc + 1;
  //               state <= ST0;
  //             end
  //     endcase
  //   end
  // end
  //
  // always_ff @ (posedge intf.CLK, negedge intf.RST) begin
  //   // このとりこみがuniBusの値反映を待たずに行われているのが問題
  //   dummyReg <= intf.uniBus;
  // end




  enum {
    ST0 = 0,
    ST1 = 1
  } state_index_t;
  logic [3:0] state, next;

  // Sequential state transition
  always_ff @(posedge intf.CLK, negedge intf.RST) begin
    if (!intf.RST) begin
      state       <= '0; // default assignment
      state[ST0]  <= 1'b1;
    end
    else
      state       <= next;
  end

  // Combinational next state logic
  always_comb begin
    next = '0;
    unique case (1'b1)
      state[ST0] : next[ST1] = 1'b1;
      state[ST1] : next[ST0] = 1'b1;
      default    : next[ST0] = 1'b1;
    endcase
  end

  // Make output assignments
  always_ff @(posedge intf.CLK, negedge intf.RST) begin
    if (!intf.RST) begin
      pc <= 0;
    end
    else begin
      unique case (1'b1)
        state[ST0] : begin
          intf.exec(intf.READ, pc);
        end
        state[ST1] : begin
          pc <= pc + 1;
          dummyReg <= intf.uniBus;
        end
        default: ;
      endcase
    end
  end

  assign intf.uniBus = (state[ST0] == 1'b1) ? pc : { 8{HIGH_IMPEDANCE} };

endmodule
