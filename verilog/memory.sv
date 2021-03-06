interface IMemory (inout wire [7:0] uniBus);
  parameter bit NOT_RUNNING = 0;
  parameter bit NOW_RUNNING = 1;

  parameter bit READ = 1;
  parameter bit WRITE = 0;

  logic isRunning = NOT_RUNNING;
  logic rW;
  logic [7:0] addressBuff;

  function void takeIn(logic rWArg, logic [7:0] address);
    if (isRunning) return;

    isRunning <= NOW_RUNNING;
    rW <= rWArg;
    addressBuff <= address;
  endfunction
endinterface




module Memory(input logic CLK, input logic RST, IMemory intf);
  parameter HIGH_IMPEDANCE = 1'bZ;

  logic [7:0] mem[255:0];

  enum {
    IDLE = 0,
    READ = 1,
    WRITE = 2
  } state_index_t;
  logic [3:0] state, next;

  function void clearState();
    intf.isRunning <= intf.NOT_RUNNING;
    intf.rW <= HIGH_IMPEDANCE;
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
      state[IDLE]  : begin
        if (intf.isRunning == intf.NOW_RUNNING) begin
          if (intf.rW == intf.READ) next[READ] = 1'b1;
          else if (intf.rW == intf.WRITE) next[WRITE] = 1'b1;
        end  else next[IDLE] = 1'b1;
      end
      state[READ]  : next[IDLE] = 1'b1;
      state[WRITE] : next[IDLE] = 1'b1;
      default      : next[IDLE] = 1'b1;
    endcase
  end

  // Make output assignments
  always_ff @(posedge CLK, negedge RST) begin
    if (!RST) begin
      clearState();
    end
    else begin
      // clock立ち上がり --> 分岐条件確定 --> レジスタ代入なので、直感より1clock遅れる
      // 従って、nextを参照する
      unique case (1'b1)
        next[READ]  : begin
          clearState();
        end
        next[WRITE] : begin
          mem[intf.addressBuff] <= intf.uniBus;
          clearState();
        end
        default: ;
      endcase
    end
  end

  assign intf.uniBus = (next[READ] == 1'b1) ? mem[intf.addressBuff] : { 8{HIGH_IMPEDANCE} };
endmodule
