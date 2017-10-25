module NopMachine(IMemory intf);
  parameter HIGH_IMPEDANCE = 1'bZ;

  logic [7:0] pc = 8'b0000_0000;
  logic [7:0] dummyReg = 8'b0000_0000;

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
