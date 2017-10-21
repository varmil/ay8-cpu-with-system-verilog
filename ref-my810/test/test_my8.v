module test_my8;
  wire [7:0] adbus;
  wire mem_do, mem_rW;

  wire [7:0] acc_out ;
  reg [7:0] sw_byte ;

  reg p_reset, m_clock;

  integer i;

  my8_mem the_my8_mem(.p_reset(p_reset), .m_clock(m_clock), .do(mem_do), .rW(mem_rW), .adbus(adbus));
  my8_core the_my8_core(.p_reset(p_reset), .m_clock(m_clock), .mem_do(mem_do), .sw_byte(sw_byte), .mem_rW(mem_rW), .adbus(adbus), .acc_out(acc_out));

  always
  begin
    #5 m_clock = 1'b0;
    #5 m_clock = 1'b1;
  end

  initial
  begin
    $dumpfile("test_my8.vcd");
    $dumpvars(0, test_my8);

    sw_byte = 8'h22;

    p_reset = 1'b0;
    m_clock = 1'b0;

    #5 p_reset = 1'b1;  // reset start

    #8; // 10 -- clock

    // 13
    p_reset = 1'b0;  // reset end

    #10000;

    $finish;
  end
endmodule
