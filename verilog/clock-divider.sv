// 10MHz --> 1Hz
module ClockDivider(input logic CLK, input logic RST, output logic dividedCLK);
  parameter DIVIDE = 23'd5000000;
  logic [22:0] tmpCount;

  always_ff @ (posedge CLK, negedge RST) begin
    if (!RST) begin
      tmpCount <= 0;
      dividedCLK <= 0;
    end
    else if (tmpCount == DIVIDE) begin
      tmpCount <= 0;
      dividedCLK <= ~dividedCLK;
    end
    else
      tmpCount <= tmpCount + 1;
  end
endmodule
