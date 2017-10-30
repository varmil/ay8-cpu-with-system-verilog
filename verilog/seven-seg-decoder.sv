// DE-10 Lite is ActiveLow
// 8bit input --> two hex
module SevenSegDecoder(input logic [7:0] in, output logic [7:0] HEXHigh, output logic [7:0] HEXLow);
  always_comb begin
    case (in[3:0])
      4'h0 : HEXLow = 8'b1100_0000;
      4'h1 : HEXLow = 8'b1111_1001;
      4'h2 : HEXLow = 8'b1010_0100;
      4'h3 : HEXLow = 8'b1011_0000;
      4'h4 : HEXLow = 8'b1001_1001;
      4'h5 : HEXLow = 8'b1001_0010;
      4'h6 : HEXLow = 8'b1000_0010;
      4'h7 : HEXLow = 8'b1101_1000;
      4'h8 : HEXLow = 8'b1000_0000;
      4'h9 : HEXLow = 8'b1001_0000;
      4'ha : HEXLow = 8'b0000_1000;
      4'hb : HEXLow = 8'b0000_0011;
      4'hc : HEXLow = 8'b1010_0111;
      4'hd : HEXLow = 8'b1010_0001;
      4'he : HEXLow = 8'b0000_0110;
      4'hf : HEXLow = 8'b1000_1110;
    endcase
  end

  always_comb begin
    case (in[7:4])
      4'h0 : HEXHigh = 8'b1100_0000;
      4'h1 : HEXHigh = 8'b1111_1001;
      4'h2 : HEXHigh = 8'b1010_0100;
      4'h3 : HEXHigh = 8'b1011_0000;
      4'h4 : HEXHigh = 8'b1001_1001;
      4'h5 : HEXHigh = 8'b1001_0010;
      4'h6 : HEXHigh = 8'b1000_0010;
      4'h7 : HEXHigh = 8'b1101_1000;
      4'h8 : HEXHigh = 8'b1000_0000;
      4'h9 : HEXHigh = 8'b1001_0000;
      4'ha : HEXHigh = 8'b0000_1000;
      4'hb : HEXHigh = 8'b0000_0011;
      4'hc : HEXHigh = 8'b1010_0111;
      4'hd : HEXHigh = 8'b1010_0001;
      4'he : HEXHigh = 8'b0000_0110;
      4'hf : HEXHigh = 8'b1000_1110;
    endcase
  end
endmodule
