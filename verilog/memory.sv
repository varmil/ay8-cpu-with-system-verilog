interface IMemory (input logic CLK, input logic RST);
  logic isRunning = 0;
  logic triggered = 0;
  logic rW;
  logic [7:0] adbus;

  task exec(logic rWArg, logic [7:0] adbusArg);
    if (isRunning) return;

    triggered <= 1;
    rW <= rWArg;
    adbus <= adbusArg;
  endtask

endinterface




module Memory(IMemory foo);
  typedef enum logic[3:0] { WRITE, READ, READY, IDLE } stateEnum;
  stateEnum state;

  logic [7:0] mem[255:0];
  logic [7:0] addressBuff;
  logic test;

  always_ff @ (posedge foo.CLK, negedge foo.RST) begin
    if (foo.RST == 0) begin
      state <= IDLE;
    end
    else begin
      case (state)
        // IDLE : ;
        IDLE : begin
                // ノンブロッキング代入する前に条件分岐を終えてる感じ
                if (test) begin
                  foo.isRunning <= 1;
                  addressBuff <= foo.adbus;
                  state <= (foo.rW) ? READ : WRITE;
                end
              end
        READ: begin
                // do nothing
                foo.isRunning <= 0;
                foo.triggered <= 0;
                state <= IDLE;
              end
        WRITE: begin
                mem[addressBuff] <= foo.adbus;
                foo.isRunning <= 0;
                foo.triggered <= 0;
                state <= IDLE;
              end
      endcase
    end
  end

  assign test = foo.triggered;

endmodule
