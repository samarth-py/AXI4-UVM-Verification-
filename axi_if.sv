interface axi_if(input logic ACLK);
logic ARESETn;
//***************************(1ST)*******************************//
//Write address channel signals.(AW)
//Master Signals
logic [3:0] AWID;
logic [31:0] AWADDR;
logic[3:0] AWLEN;
logic[2:0] AWSIZE;
logic[1:0] AWBURST;
logic AWVALID;
//Slave Signal
logic AWREADY;
//****************************(2ND)******************************//
//Write data channel signals(W)
//Master Signals
logic[3:0]  WID;
logic[31:0] WDATA;
logic[3:0] WSTRB;
logic WLAST;
logic WVALID;
//Slave Signal
logic WREADY;
//***************************(3RD)*******************************//
//Write response channel signals(B)
//Master Signal
logic BREADY;
//Slave signals
logic[3:0] BID;
logic[1:0] BRESP;
logic BVALID;
//*****************************(4TH)*****************************//
//Read Address channel signals(AR)
//Master Signals
logic[3:0] ARID;
logic[31:0] ARADDR;
logic[3:0] ARLEN;
logic[2:0] ARSIZE;
logic[1:0] ARBURST;
logic ARVALID;
//Slave Signal
logic ARREADY;
//*****************************(5TH)*****************************//
//Read data channel signals(R)
//Master Signal
logic RREADY;
logic RVALID;
//Slave Signal
logic RID;
logic RDATA;
logic RRESP;
logic RLAST;
//*****************************(CLOCKING BLOCKS)*****************************//
clocking msdr@(posedge ACLK);
default input #1 output #0; 
output AWADDR,AWVALID,AWID,AWLEN,AWBURST,AWSIZE;
output WDATA,WVALID,WID, WSTRB, WLAST;
output BREADY;
output ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
output RREADY;
output ARESETn;
input AWREADY;
input WREADY;
input BRESP,BID;
input BVALID;
input ARREADY;
input RID,RDATA,RRESP,RLAST,RVALID;
endclocking

clocking sldr@(posedge ACLK);
default input #1 output #0; 
input AWADDR,AWVALID,AWID,AWLEN,AWBURST,AWSIZE;
input WDATA,WVALID,WID, WSTRB, WLAST;
input BREADY;
input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
input RREADY;
input ARESETn;
output AWREADY;
output WREADY;
output BRESP;
output BVALID,BID;
output ARREADY;
output RID,RDATA,RRESP,RLAST,RVALID;
endclocking

clocking slmon@(posedge ACLK);
default input #1 output #0; 
input ARESETn,AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID,AWREADY;
input WID,WDATA,WSTRB,WLAST,WVALID,WREADY;
input BREADY,BID,BRESP,BVALID;
input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID,ARREADY;
input RREADY,RID,RDATA,RRESP,RLAST,RVALID;
endclocking

clocking msmon@(posedge ACLK);
default input #1 output #0; 
input ARESETn,AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID,AWREADY;
input WID,WDATA,WSTRB,WLAST,WVALID,WREADY;
input BREADY,BID,BRESP,BVALID;
input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID,ARREADY;
input RREADY,RID,RDATA,RRESP,RLAST,RVALID;
endclocking


//*****************************(MODPORT)************************************//
modport m1(clocking msdr);
modport m2(clocking sldr);
modport m3(clocking msmon);
modport m4(clocking slmon);
endinterface
