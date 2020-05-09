`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 04:23:38 PM
// Design Name: 
// Module Name: AXI4_LITE_Test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI4_LITE_Test #(parameter data_width = 32) ();

reg clk;
reg reset;

reg instr_req_o;             //Read request from IP 
wire instr_rvalid_i;
wire instr_gnt_i;
/////////////////////////////////////////////////
/////////////////Data Request///////////////////
reg  data_req_o;
reg  data_we_o;
wire data_gnt_i;
wire data_rvalid_i;

reg [31:0] Addr;

wire [data_width-1 : 0] Read_Data ;
reg [data_width-1 : 0] Write_Data;
//////////////////////////////////////////////
wire AWvalid;
 reg AWready;
 wire [31:0] AWaddr;
 //output  [2:0] AWprot,
 
 //Write Data Channel
 wire Wvalid;
 reg Wready;
 wire [data_width-1 : 0] Wdata;
 wire [data_width/8 -1 : 0] Wstrb;
 
 //Write response
 reg Bvalid;
 wire Bready;
 reg [1:0] Bresp;
 
 
 
 
 //Read Address
 wire ARvalid;
 reg ARready;
 wire [31:0] ARaddr;
 //input [2:0] ARprot,
 
 //Read Data Channel
 reg Rvalid;
 wire Rready;
 reg [data_width-1 : 0]Rdata;
  reg  [1:0] Rresp;

 ////////////////////////////////////////////////////////////
 AXI4_Lite_interface  AXI1(.Rresp(Rresp),.clk(clk) ,.reset(reset),

 . Addr(Addr),
 . Read_Data(Read_Data),
 . ARvalid(ARvalid),
  .ARready(ARready),
 . ARaddr(ARaddr),
  .Rvalid(Rvalid),
  .Rready(Rready),
  .Rdata(Rdata),
  .Write_Data(Write_Data),
  .AWvalid(AWvalid),
  .AWready(AWready),
  .AWaddr(AWaddr),
  .Wvalid(Wvalid),
  .Wready(Wready),
  .Wdata(Wdata),
  .Wstrb(Wstrb),
  .Bvalid(Bvalid),
  .Bready(Bready),
  .Bresp(Bresp),
  .instr_req_o(instr_req_o),
  .instr_rvalid_i(instr_rvalid_i),
  .instr_gnt_i(instr_gnt_i),
  .data_req_o(data_req_o),
  .data_we_o(data_we_o),
  .data_gnt_i(data_gnt_i),
  .data_rvalid_i(data_rvalid_i)
  );
  initial
   begin
      clk=1'b1;  reset=1'b1;  // RESET
	  
	  
	  
      #100 reset=1'b0; 
  end
 always #50 clk = ~clk;
 
 initial 
  begin
  Rresp=2'b00;
 instr_req_o= 0;
  data_req_o = 0;
  data_we_o=1;
  Wready=1'b0;
  Bresp = 2'b00;
  Bvalid=1;
  Addr = 32'hffffffff;
   
   //Read transaction test
   Rdata = 32'hffffcccc;
   ARready=1'b1;
   Rvalid=1'b1;
   #5 reset = 0;
   #6 reset = 1;
   #10 instr_req_o=1'b1; data_req_o=1'b1;
  
   #15 instr_req_o=1'b0;
   
   //////////////Write test/////////////////////
  /*  Write_Data = 32'hAAAACCCC;  
  AWready=1'b1; Wready=1'b1;
  
   #5 reset = 0;
   #6 reset = 1;
  
   #50 data_req_o=1'b1; 
 */
 
 end

  
endmodule
