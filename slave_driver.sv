class slave_driver extends uvm_driver #(axi_xtn);
`uvm_component_utils(slave_driver);
virtual axi_if.m2 vif;
slave_config sl_cfg;
axi_xtn q1[$];
axi_xtn q2[$];
axi_xtn q3[$]; 
axi_xtn xtn,xtn1;
int count,ending;

semaphore sem1=new(1);
semaphore sem2=new();
semaphore sem3=new(1);
semaphore sem4=new();
semaphore sem5=new(1);
semaphore sem6=new();
semaphore sem7=new(1);
semaphore sem8=new(1);
 
extern function new(string name ="slave_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

extern task send();
extern task waddr(axi_xtn xtn);
extern task wdata(axi_xtn xtn);
extern task wresp(axi_xtn xtn);
extern task rdata(axi_xtn xtn);
extern task raddr();
endclass

function slave_driver::new(string name ="slave_driver",uvm_component parent);
super.new(name,parent);
endfunction

function void slave_driver::build_phase(uvm_phase phase);
if(!uvm_config_db #(slave_config)::get(this,"","slave_config",sl_cfg))
  `uvm_fatal("slave_driver","cannot get config data")

super.build_phase(phase);
endfunction 

function void slave_driver::connect_phase(uvm_phase phase);
vif=sl_cfg.vif;
endfunction

task slave_driver::run_phase(uvm_phase phase);
//seq_item_port.get_next_item(req);
forever
send();
//seq_item_port.item_done();
endtask

task slave_driver::waddr(axi_xtn xtn);
//xtn=axi_xtn::type_id::create("this");
$display("slave-waddr");
@(vif.sldr);
vif.sldr.AWREADY<=1'b1;
@(vif.sldr);
wait(vif.sldr.AWVALID)
xtn.AWADDR<=vif.sldr.AWADDR;
xtn.AWID<=vif.sldr.AWID;
xtn.AWLEN<=vif.sldr.AWLEN;
xtn.AWBURST<=vif.sldr.AWBURST;
xtn.AWSIZE<=vif.sldr.AWSIZE;
vif.sldr.AWREADY<=1'b0;
q1.push_back(xtn);
q2.push_back(xtn);
$display("slave-waddr--ended");

endtask

task slave_driver::wdata(axi_xtn xtn);
int mem[int];
xtn.cal_addr();

        $displayh("aligned:%h",xtn.aligned_addr);
           $displayh("addresses calculated in slave side are %p",xtn.addr);
          for(int i=0;i<(xtn.AWLEN+1);i++)
                 begin
                      vif.sldr.WREADY<=1;
                      @(vif.sldr);
                          wait(vif.sldr.WVALID)

            $display("slave driver start of awvalid");
                                  $display("WSTRB in slave driver is:%p",vif.sldr.WSTRB);
                                 if(vif.sldr.WSTRB==15)
                                        mem[xtn.addr[i]]=vif.sldr.WDATA;

                               if(vif.sldr.WSTRB==8)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[31:24];

                                  if(vif.sldr.WSTRB==4)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[23:16];

                                  if(vif.sldr.WSTRB==2)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[15:8];

                                  if(vif.sldr.WSTRB==1)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[7:0];

                                  if(vif.sldr.WSTRB==7)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[23:0];

                                  if(vif.sldr.WSTRB==14)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[31:8];

                                  if(vif.sldr.WSTRB==12)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[31:16];

                                  if(vif.sldr.WSTRB==3)
                                         mem[xtn.addr[i]]=vif.sldr.WDATA[15:0];



                           $displayh("value inside mem is: %p",mem[xtn.addr[i]]);
                           vif.sldr.WREADY<=0;
                          repeat($urandom_range(1,5))
                          @(vif.sldr);
                          count=1;
                   end
             $displayh("memory is %p",mem);

            $display("end of read_data");
endtask

task slave_driver::wresp(axi_xtn xtn);
$display("start slave wresp");
//xtn=axi_xtn::type_id::create("this");
 vif.sldr.BVALID<=1;
 vif.sldr.BRESP<=0;
 vif.sldr.BID<=xtn.BID;
 $display("BID sent is %d",xtn.AWID);
@(vif.sldr);
wait(vif.sldr.BREADY)
vif.sldr.BVALID<=0;
vif.sldr.BRESP<='hx;

repeat($urandom_range(1,5))
    @(vif.sldr);
$display("end of slave wresp");
endtask

task slave_driver::raddr();
$display("start of slave_raddr");
           xtn1=axi_xtn::type_id::create("xtn");
            repeat($urandom_range(1,5))
                  @(vif.sldr);
            vif.sldr.ARREADY <= 1;

            wait(vif.sldr.ARVALID)
                   xtn1.ARID=vif.sldr.ARID;
                   xtn1.ARLEN=vif.sldr.ARLEN;
                   xtn1.ARSIZE=vif.sldr.ARSIZE;
                   xtn1.ARBURST=vif.sldr.ARBURST;
                 //  xtn1.ARVALID=vif.sldr.ARVALID;

                  q3.push_back(xtn1);
                   repeat($urandom_range(1,5))
                    @(vif.sldr);

            vif.sldr.ARREADY <= 0;

           $display("end of slave_raddr");
endtask


task slave_driver::rdata(axi_xtn xtn);
int length = xtn1.ARLEN;
            $display("start slave rdata");
        for(int i=0; i<length+1; i++)
        begin
                vif.sldr.RDATA<= $urandom;
             //   $displayh("slave received address:%0p, data;%0d",xtn.addr,vif.sldr.RDATA);
              //  $displayh("RDATA SENt is : %h",vif.sldr.RDATA);
                vif.sldr.RVALID<= 1;
                vif.sldr.RID<= xtn1.ARID;
                vif.sldr.RRESP <= 0;
                if(i==(length))
                        vif.sldr.RLAST <= 1;
                else
                        vif.sldr.RLAST <= 0;

                @(vif.sldr);
                wait(vif.sldr.RREADY)
                vif.sldr.RVALID <= 0;
                vif.sldr.RLAST <= 0;
                vif.sldr.RRESP <= 'hz;
           
                repeat($urandom_range(1,5))
                  @(vif.sldr);
               count=1;
        end

            $display("end of slave rdata");
endtask

task slave_driver::send();
xtn=axi_xtn::type_id::create("xtn");
fork
begin 
sem1.get(1);
waddr(xtn);
sem1.put(1);
sem2.put(1);
end

begin 
sem2.get(1);
sem3.get(1);
wdata(q1.pop_front());
sem3.put(1);
sem4.put(1);
end

begin
sem4.get(1);
sem5.get(1);
wresp(q2.pop_front());
sem5.put(1);
end

begin 
sem7.get(1);
raddr();
sem7.put(1);
sem6.put(1);
end

begin 
sem6.get(1);
sem8.get(1);
rdata(q3.pop_front());
sem8.put(1);
end
join_any
endtask
