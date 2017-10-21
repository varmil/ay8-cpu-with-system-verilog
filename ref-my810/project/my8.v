module my8 (input p_reset, input m_clock, input [7:0] sw_byte, output [7:0] acc_out);
  wire [7:0] adbus ;
  wire mem_do, mem_rW ;

  my8_mem the_my8_mem(.p_reset(p_reset), .m_clock(m_clock), .do(mem_do), .rW(mem_rW), .adbus(adbus));
  my8_core the_my8_core(.p_reset(p_reset), .m_clock(m_clock), .mem_do(mem_do), .sw_byte(sw_byte), .mem_rW(mem_rW), .adbus(adbus), .acc_out(acc_out));
endmodule
