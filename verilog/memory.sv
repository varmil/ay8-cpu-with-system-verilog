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
  logic shouldOutput;

  function void clearState();
    shouldOutput = 1'b0;
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
                      shouldOutput <= 1'b1;
                      clearState();
                    end
        writeState : begin
                      mem[intf.addressBuff] <= intf.uniBus;
                      clearState();
                    end
        default : ;
      endcase

      // output for uniBus should continue 1 cycle
      if (shouldOutput) shouldOutput <= ~shouldOutput;
    end
  end

  assign state = { intf.isRunning, intf.rW };
  assign readState = { intf.NOW_RUNNING, intf.READ };
  assign writeState = { intf.NOW_RUNNING, intf.WRITE };
  assign intf.uniBus = (shouldOutput) ? mem[intf.addressBuff] : { 8{HIGH_IMPEDANCE} };
endmodule
