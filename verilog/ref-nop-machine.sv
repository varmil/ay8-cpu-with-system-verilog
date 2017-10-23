/*Produced by NSL Core(version=20170103), IP ARCH, Inc. Mon Oct 23 14:53:55 2017
 Licensed to :EVALUATION USER*/
/*
 DO NOT USE ANY PART OF THIS FILE FOR COMMERCIAL PRODUCTS.
*/

module my8_mem ( p_reset , m_clock , adbus , rW , exec );
  input p_reset, m_clock;
  wire p_reset, m_clock;
inout [7:0] adbus;
wire [7:0] adbus;
  input rW;
  wire rW;
  input exec;
  wire exec;
  wire running;
  reg [7:0] memory_cell [0:255];
  reg [7:0] addr_buf;
  reg _reg_0;
  reg _reg_1;
  reg _reg_2;
  reg _reg_3;
  wire _reg_1_goto;
  wire _reg_0_goin;
  wire _reg_2_goto;
  wire _reg_3_goto;
  wire _net_4;
  wire _net_5;
  wire _net_6;
  wire _net_7;
  wire _reg_2_goin;
  wire _net_8;
  wire _net_9;
  wire _reg_1_goin;
  wire _net_10;
  wire _net_11;
  wire _net_12;
  wire _net_13;

   assign  running = (_reg_2|_reg_1);
   assign  _reg_1_goto = _reg_1;
   assign  _reg_0_goin = (_net_5|(_reg_2|_reg_1));
   assign  _reg_2_goto = _reg_2;
   assign  _reg_3_goto = (_net_9|(_net_7|_net_4));
   assign  _net_4 = ((exec|_reg_3)&(running != 1'b0));
   assign  _net_5 = ((exec|_reg_3)&(running != 1'b0));
   assign  _net_6 = ((exec|_reg_3)&(~(running != 1'b0)));
   assign  _net_7 = (((exec|_reg_3)&(~(running != 1'b0)))&(rW != 1'b0));
   assign  _reg_2_goin = _net_8;
   assign  _net_8 = (((exec|_reg_3)&(~(running != 1'b0)))&(rW != 1'b0));
   assign  _net_9 = (((exec|_reg_3)&(~(running != 1'b0)))&(~(rW != 1'b0)));
   assign  _reg_1_goin = _net_10;
   assign  _net_10 = (((exec|_reg_3)&(~(running != 1'b0)))&(~(rW != 1'b0)));
   assign  _net_11 = (((((exec|_reg_3)&(~(running != 1'b0)))&(rW != 1'b0))|(exec&(~_reg_3_goto)))|(_reg_2|_reg_3));
   assign  _net_12 = ((((exec|_reg_3)&(~(running != 1'b0)))&(~(rW != 1'b0)))|(_reg_1|_reg_2));
   assign  _net_13 = (((((exec|_reg_3)&(running != 1'b0))|_reg_2)|_reg_1)|(_reg_0|_reg_1));
   assign  adbus = (_reg_2)?(memory_cell[addr_buf]):8'bZ;
always @(posedge m_clock)
  begin
   if (_reg_1 )
     memory_cell[addr_buf] <= adbus;
end
always @(posedge m_clock)
  begin
if ((_net_6))
      addr_buf <= adbus;
end
always @(posedge m_clock or posedge p_reset)
  begin
if (p_reset)
     _reg_0 <= 1'b0;
else if ((_net_13))
      _reg_0 <= (((((exec|_reg_3)&(running != 1'b0))|_reg_2)|_reg_1)|(_reg_1&(~_reg_1_goto)));
end
always @(posedge m_clock or posedge p_reset)
  begin
if (p_reset)
     _reg_1 <= 1'b0;
else if ((_net_12))
      _reg_1 <= ((((exec|_reg_3)&(~(running != 1'b0)))&(~(rW != 1'b0)))|(_reg_2&(~_reg_2_goto)));
end
always @(posedge m_clock or posedge p_reset)
  begin
if (p_reset)
     _reg_2 <= 1'b0;
else if ((_net_11))
      _reg_2 <= (((((exec|_reg_3)&(~(running != 1'b0)))&(rW != 1'b0))|(_reg_3&(~_reg_3_goto)))|(exec&(~_reg_3_goto)));
end
always @(posedge m_clock or posedge p_reset)
  begin
if (p_reset)
     _reg_3 <= 1'b0;
else if ((_reg_3))
      _reg_3 <= 1'b0;
end
endmodule

/*Produced by NSL Core(version=20170103), IP ARCH, Inc. Mon Oct 23 14:53:55 2017
 Licensed to :EVALUATION USER*/










 /*Produced by NSL Core(version=20170103), IP ARCH, Inc. Mon Oct 23 14:54:46 2017
  Licensed to :EVALUATION USER*/
 /*
  DO NOT USE ANY PART OF THIS FILE FOR COMMERCIAL PRODUCTS.
 */

 module my8_nopmachine ( p_reset , m_clock , adbus , mem_rW , mem_do );
   input p_reset, m_clock;
   wire p_reset, m_clock;
 inout [7:0] adbus;
 wire [7:0] adbus;
   output mem_rW;
   wire mem_rW;
   output mem_do;
   wire mem_do;
   reg init;
   reg [7:0] pc;
   reg [7:0] dummyreg;
   wire main;
   wire _net_0;
   reg _reg_1;
   reg _reg_2;
   wire _reg_1_goto;
   wire _reg_2_goin;
   wire _net_3;
   wire _net_4;
   wire _net_5;
   wire _net_6;
   wire _net_7;

    assign  main = _net_0;
    assign  _net_0 = (init != 1'b0);
    assign  _reg_1_goto = _reg_1;
    assign  _reg_2_goin = _reg_1;
    assign  _net_3 = (main|_reg_2);
    assign  _net_4 = (main|_reg_2);
    assign  _net_5 = (main|_reg_2);
    assign  _net_6 = (_reg_1|_reg_2);
    assign  _net_7 = (main|(_reg_1|_reg_2));
    assign  adbus = (_net_4)?pc:8'bZ;
    assign  mem_rW = _net_5;
    assign  mem_do = _net_3;
 always @(posedge m_clock or posedge p_reset)
   begin
 if (p_reset)
      init <= 1'b1;
 else   init <= 1'b0;
 end
 always @(posedge m_clock or posedge p_reset)
   begin
 if (p_reset)
      pc <= 8'b00000000;
 else if ((_reg_1))
       pc <= (pc+8'b00000001);
 end
 always @(posedge m_clock)
   begin
 if ((_reg_1))
       dummyreg <= adbus;
 end
 always @(posedge m_clock or posedge p_reset)
   begin
 if (p_reset)
      _reg_1 <= 1'b0;
 else if ((_net_7))
       _reg_1 <= (_reg_2|main);
 end
 always @(posedge m_clock or posedge p_reset)
   begin
 if (p_reset)
      _reg_2 <= 1'b0;
 else if ((_net_6))
       _reg_2 <= _reg_1;
 end
 endmodule

 /*Produced by NSL Core(version=20170103), IP ARCH, Inc. Mon Oct 23 14:54:46 2017
  Licensed to :EVALUATION USER*/




  // check_nopmachne.v
module check_nopmachne;
  wire [7:0] adbus_wire;
  wire mem_do, mem_rW;
  reg p_reset, m_clock;

  my8_mem the_my8_mem(
      .p_reset(p_reset), .m_clock(m_clock),
      .adbus(adbus_wire), .exec(mem_do), .rW(mem_rW)
  );
  my8_nopmachine the_my8_nopmachine(
      .p_reset(p_reset), .m_clock(m_clock),
      .adbus(adbus_wire), .mem_do(mem_do), .mem_rW(mem_rW)
  );

  always
  begin
    #5 m_clock = 1'b0;
    #5 m_clock = 1'b1;
  end

  initial begin
    the_my8_mem.memory_cell[0] = 8'h10;
    the_my8_mem.memory_cell[1] = 8'h11;
    the_my8_mem.memory_cell[2] = 8'h12;
    the_my8_mem.memory_cell[3] = 8'h13;
  end

  initial begin
    // $dumpfile("check_nopmachine.vcd");
    // $dumpvars(0, the_my8_nopmachine);
    p_reset = 1'b0;
    m_clock = 1'b0;

    #5 p_reset = 1'b1; // reset start

    #8; // 10 -- clock

    // 13
    p_reset = 1'b0; // reset end

    #200;
    $finish;
  end
endmodule
