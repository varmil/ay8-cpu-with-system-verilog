interface IMemory (input logic CLK, input logic RST, inout wire [7:0] uniBus);
  parameter bit NOT_RUNNING = 0;
  parameter bit NOW_RUNNING = 1;

  parameter bit READ = 1;
  parameter bit WRITE = 0;

  logic isRunning = NOT_RUNNING;
  logic rW;
  logic [7:0] addressBuff;

  function void exec(logic rWArg, logic [7:0] address);
    if (isRunning) return;

    isRunning <= NOW_RUNNING;
    rW <= rWArg;
    addressBuff <= address;
  endfunction
endinterface




module Memory(IMemory intf);
  // typedef enum logic[3:0] { WRITE, READ, READY, IDLE } stateEnum;
  // stateEnum state;

  parameter HIGH_IMPEDANCE = 1'bZ;

  logic [7:0] mem[255:0];
  logic [1:0] state, readState, writeState;

  function void clearState();
    intf.isRunning <= intf.NOT_RUNNING;
    intf.rW <= HIGH_IMPEDANCE;
  endfunction

  always @ (posedge intf.CLK, negedge intf.RST) begin
    if (intf.RST == 0) begin
      clearState();
    end
    else begin
      // ノンブロッキング代入する前に条件分岐を終えてる感じ
      case (state)
        readState : begin
                      clearState();
                    end
        writeState : begin
                      mem[intf.addressBuff] <= intf.uniBus;
                      clearState();
                    end
        default : ;
      endcase
    end
  end





  // enum {
  //   IDLE = 0,
  //   READ = 1,
  //   WRITE = 2
  // } state_index_t;
  // logic [3:0] state, next;
  //
  // // Sequential state transition
  // always_ff @(posedge intf.CLK, negedge intf.RST) begin
  //   if (!intf.RST) begin
  //     state       <= '0; // default assignment
  //     state[IDLE] <= 1'b1;
  //   end
  //   else
  //     state       <= next;
  // end
  //
  // // Combinational next state logic
  // always_comb begin
  //   next = '0;
  //   unique case (1'b1)
  //     state[IDLE]  : begin
  //       if (condition1) begin
  //
  //       end else if (${2:condition2) begin
  //
  //       end else begin
  //
  //       end
  //       if (intf.rW ==) next[READ] = 1'b1;
  //       if (goWrite) next[WRITE] = 1'b1;
  //     end
  //     state[READ]  : next[IDLE] = 1'b1;
  //     state[WRITE] : next[IDLE] = 1'b1;
  //     default      : next[IDLE] = 1'b1;
  //   endcase
  // end
  //
  // // Make output assignments
  // always_ff @(posedge intf.CLK, negedge intf.RST) begin
  //   if (!intf.RST) begin
  //   end
  //   else begin
  //     unique case (1'b1)
  //       state[IDLE]  : begin
  //       end
  //       state[READ]  : begin
  //       end
  //       state[WRITE] : begin
  //       end
  //       default: ;
  //     endcase
  //   end
  // end







  assign state = { intf.isRunning, intf.rW };
  assign readState = { intf.NOW_RUNNING, intf.READ };
  assign writeState = { intf.NOW_RUNNING, intf.WRITE };
  assign intf.uniBus = (state == readState) ? mem[intf.addressBuff] : { 8{HIGH_IMPEDANCE} };
endmodule
