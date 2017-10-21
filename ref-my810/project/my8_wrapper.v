`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:14:47 12/15/2011 
// Design Name: 
// Module Name:    my8_wrapper 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module my8_wrapper (
    input sw_in,
    input m_clock,
    input [7:0] sw_byte,
	 output led_out,
	 output sevenseg_dig1, sevenseg_dig2,
    output [6:0] sevenseg
    );
	 
wire p_reset, sevenseg_select;
wire [6:0] sevenseg_tmp;

assign led_out = 1'b1;

assign p_reset = ~sw_in;

assign sevenseg_dig2 = ~sevenseg_select;
assign sevenseg_dig1 = sevenseg_select;
assign sevenseg = ~sevenseg_tmp;

my8_wrapper_nsl instance_name (
    .p_reset(p_reset), 
    .m_clock(m_clock), 
    .sw_byte(sw_byte), 
    .sevenseg_select(sevenseg_select), 
    .sevenseg(sevenseg_tmp)
    );

endmodule
