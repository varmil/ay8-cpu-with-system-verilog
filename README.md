# ay8-cpu-with-system-verilog
create original 8bit CPU with SystemVerilog !

#### Nop Machine
![image 1](https://user-images.githubusercontent.com/6558862/31894758-45246c34-b84a-11e7-8426-9a2561ecd47c.png)

#### fetch & dec_exec pipeline 
![image](https://user-images.githubusercontent.com/6558862/32143799-8293914c-bcf2-11e7-8bbd-78f573b1537f.png)

* 15: pc --> uniBus
* 25 - 45: 
  * memory: read 8'h00 ram data --> uniBus
  * dataflow: store uniBus data to BufferRegister --> IRRegister
  * ALU: do NOP 
  * PC++ --> uniBus
* 45 - 65
  * memory: read 8'h01 ram data --> uniBus
  * dataflow: store uniBus data to BufferRegister --> IRRegister
  * ALU: do first IR (8'h00)
  * PC++ --> uniBus
