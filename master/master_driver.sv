   class master_driver extends uvm_driver#(axi_xtn);
    `uvm_component_utils(master_driver)

    virtual axi_if.m1 mif;
    master_config mst_cfg_h;

    axi_xtn xtn;
        axi_xtn q1[$], q2[$],q3[$],q4[$],q5[$];
        semaphore sem_awdc = new();
        semaphore sem_wdrc = new();
        semaphore sem_wdc = new(1);
        semaphore sem_awc = new(1);
        semaphore sem_wrc = new(1);

       semaphore sem_ardc = new();
       semaphore sem_arc = new(1);
       semaphore sem_rdc = new(1);

    extern function new(string name = "master_driver", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
        extern task  run_phase(uvm_phase phase);
        extern task drive(axi_xtn xtn);
        extern task drive_awaddr(axi_xtn xtn);
        extern task drive_wdata(axi_xtn xtn);
        extern task drive_bresp(axi_xtn xtn);

        extern task drive_raddr(axi_xtn xtn);
        extern task drive_rdata(axi_xtn xtn);
endclass: master_driver

    function master_driver::new(string name = "master_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void master_driver::build_phase(uvm_phase phase);
        if(!uvm_config_db#(master_config)::get(this, "", "master_config", mst_cfg_h))
            `uvm_fatal("Master Driver", "getting config failed");
            super.build_phase(phase);
    endfunction

    function void master_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
     mif=mst_cfg_h.vif;
    endfunction

        task master_driver::run_phase(uvm_phase phase);
              //  $display("here inside driver's run phase");
                forever
                begin
                        seq_item_port.get_next_item(req);
                        drive(req);
                //      #10;
                        seq_item_port.item_done();

                req.print();
                end
        endtask

        task master_driver::drive(axi_xtn xtn);
        q1.push_back(xtn);
        q2.push_back(xtn);
        q3.push_back(xtn);
        q4.push_back(xtn);
           fork
               begin
                        sem_awc.get(1);
                        drive_awaddr(q1.pop_front());
                        sem_awdc.put(1);
                        sem_awc.put(1);
                end

               begin
                        sem_awdc.get(1);
                        sem_wdc.get(1);
                        drive_wdata(q2.pop_front());
                        sem_wdc.put(1);
                        sem_wdrc.put(1);
                end

                begin
                        sem_wdrc.get(1);
                        sem_wrc.get(1);
                        drive_bresp(q3.pop_front());
                        sem_wrc.put(1);
                end

                begin
                        sem_arc.get(1);
                        drive_raddr(q4.pop_front());
                        sem_arc.put(1);
                        sem_ardc.put(1);
                end
                begin
                        sem_ardc.get(1);
                        sem_rdc.get(1);
                        drive_rdata(q5.pop_front());
                        sem_rdc.put(1);
                end  
           join_any
      endtask

        task master_driver::drive_awaddr(axi_xtn xtn);
                $display("start of drive_awaddr");
                mif.msdr.AWVALID <= 1;                                 //made changes here
                mif.msdr.AWADDR <= xtn.AWADDR;
                mif.msdr.AWSIZE <= xtn.AWSIZE;
                mif.msdr.AWID <= xtn.AWID;
                mif.msdr.AWLEN <= xtn.AWLEN;
                mif.msdr.AWBURST <= xtn.AWBURST;

                @(mif.msdr);
                wait(mif.msdr.AWREADY)
                mif.msdr.AWVALID <= 0;

                repeat($urandom_range(1,5))
                        @(mif.msdr);

                $display("end of drive_awaddr");
        endtask

        task master_driver::drive_wdata(axi_xtn xtn);
             //   $displayh("waddr is %p,wdata is %p",xtn.AWADDR,xtn.WDATA);

                $display("start of drive_wdata");
        foreach(xtn.WDATA[i])
                   //    for(int i=0;i<=xtn.WDATA.size();i++)
                        begin
                                mif.msdr.WVALID <= 1;
                                mif.msdr.WDATA <= xtn.WDATA[i];
                                mif.msdr.WSTRB <= xtn.WSTRB[i];
                                mif.msdr.WID <= xtn.WID;
                                if(i==(xtn.AWLEN))
                                        mif.msdr.WLAST <= 1;
                                else
                                        mif.msdr.WLAST <= 0;

                                @(mif.msdr);
                                wait(mif.msdr.WREADY)
                                    mif.msdr.WVALID <= 0;
                                    mif.msdr.WLAST <= 0;

                                repeat($urandom_range(1,5))
                                        @(mif.msdr);
                        end

                $display("end of drive_wdata");
        endtask

        task master_driver::drive_bresp(axi_xtn xtn);
                $display("start of drive_bresp");
          // repeat($urandom_range(1,5))
            //   @(mif.msdr);
            mif.msdr.BREADY<=1;
           @(mif.msdr)
           wait(mif.msdr.BVALID)
              mif.msdr.BREADY<=0;
           repeat($urandom_range(1,5))
               @(mif.msdr);
            $display("end of drive_bresp");
        endtask

      task master_driver:: drive_raddr(axi_xtn xtn);
                $display("start of drive_raddr");
           repeat($urandom_range(1,5))
                  @(mif.msdr);
           mif.msdr.ARID<=xtn.ARID;
           mif.msdr.ARLEN<=xtn.ARLEN;
           mif.msdr.ARSIZE<=xtn.ARSIZE;
           mif.msdr.ARBURST<=xtn.ARBURST;
           mif.msdr.ARADDR<=xtn.ARADDR;
           mif.msdr.ARVALID<=1;                   //made change here
           q5.push_back(xtn);
                 @(mif.msdr);
            $display("inside drive_raddr before wait ARREADY");
                 wait(mif.msdr.ARREADY)
                    mif.msdr.ARVALID<=0;
              repeat($urandom_range(1,5))
                    @(mif.msdr);

                $display("end of drive_raddr");
          //   `uvm_fatal("a","a")
        endtask

        task master_driver::drive_rdata(axi_xtn xtn);
         int mem[int];
         $display("start of drive_rdata");
         xtn.cal_raddr();
         xtn.strb_rcal();
           for(int i=0;i<(xtn.ARLEN+1);i++)
                 begin
                      mif.msdr.RREADY<=1;
                      @(mif.msdr);
                      wait(mif.msdr.RVALID)
                                         //mem[xtn.raddr[i]]=mif.msdr.RDATA;
                                 if(xtn.RSTRB[i]==15)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA;

                                 if(xtn.RSTRB[i]==8)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[31:24];

                                  if(xtn.RSTRB[i]==4)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[23:16];

                                  if(xtn.RSTRB[i]==2)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[15:8];

                                  if(xtn.RSTRB[i]==1)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[7:0];

                                  if(xtn.RSTRB[i]==7)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[23:0];

                                  if(xtn.RSTRB[i]==14)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[31:8];

                                  if(xtn.RSTRB[i]==12)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[31:16];

                                  if(xtn.RSTRB[i]==3)
                                         mem[xtn.raddr[i]]=mif.msdr.RDATA[15:0];
                     //input RID,RDATA,RRESP,RLAST,RVALID,RREADY;
                           mif.msdr.RREADY<=0;
                         repeat($urandom_range(1,5))
                          @(mif.msdr);

                   end
           //  `uvm_fatal("a","a")
             $displayh("master received address:%p",xtn.raddr);
             $displayh("memory received in master driver is %p",mem);

                  $display("end of drive_rdata");
        endtask




/*class master_driver extends uvm_driver #(axi_xtn);
`uvm_component_utils(master_driver)
virtual axi_if.m1 vif;
master_config ms_cfg;
semaphore sem1=new(1);
semaphore sem2=new();
semaphore sem3=new(1);
semaphore sem4=new();
semaphore sem5=new(1);
semaphore sem6=new();
semaphore sem7=new(1);
semaphore sem8=new(1);

axi_xtn xtn;
axi_xtn q1[$];
axi_xtn q2[$];
axi_xtn q3[$]; 
axi_xtn q4[$];
axi_xtn q5[$]; 

extern function new(string name ="master_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task send_to_dut(axi_xtn xtn);
extern task waddr(axi_xtn xtn);
extern task wdata(axi_xtn xtn);
extern task wresp(axi_xtn xtn);
extern task rdata(axi_xtn xtn);
extern task raddr(axi_xtn xtn);
//extern function void report_phase(uvm_phase phase);
endclass

function master_driver::new(string name ="master_driver",uvm_component parent);
super.new(name,parent);
endfunction

function void master_driver::build_phase(uvm_phase phase);
if(!uvm_config_db #(master_config)::get(this,"","master_config",ms_cfg))
		`uvm_fatal("master_driver","cannot get config data")
//uvm_config_db #(master_config)::get(this,"","master_config",ms_cfg);
//super.build_phase(phase);
super.build_phase(phase);

endfunction 

function void master_driver::connect_phase(uvm_phase phase);
super.connect_phase(phase);
vif=ms_cfg.vif;
endfunction

task master_driver::run_phase(uvm_phase phase);
forever
begin
seq_item_port.get_next_item(req);
send_to_dut(req);
seq_item_port.item_done();
end
endtask

task master_driver::waddr(axi_xtn xtn);
$display("msdr-waddr");
@(vif.msdr);
vif.msdr.AWVALID<=1'b1;
vif.msdr.AWADDR<=xtn.AWADDR;
vif.msdr.AWID<=xtn.AWID;
vif.msdr.AWLEN<=xtn.AWLEN;
vif.msdr.AWBURST<=xtn.AWBURST;
vif.msdr.AWSIZE<=xtn.AWSIZE;
@(vif.msdr);
wait(vif.msdr.AWREADY)
vif.msdr.AWVALID<=1'b0;
$display("msdr-ended-waddr");
endtask

task master_driver::wdata(axi_xtn xtn);
$display("msdr-wdata");
foreach(xtn.WDATA[i])
begin
@(vif.msdr);
vif.msdr.WVALID<=1'b1;
vif.msdr.WDATA<=xtn.WDATA[i];
vif.msdr.WID<=xtn.WID;
vif.msdr.WSTRB<=xtn.WSTRB[i];
if (i==xtn.WDATA.size-1)
vif.msdr.WLAST<=1'b1;
else
vif.msdr.WLAST<=1'b0;
@(vif.msdr);
wait(vif.msdr.WREADY)
vif.msdr.WVALID<=1'b0;
vif.msdr.WLAST<=1'b0;
$display("msdr-ended-wdata");

end
endtask

task master_driver::wresp(axi_xtn xtn);
$display("wresp-started");
@(vif.msdr);
vif.msdr.BREADY<=1'b1;
@(vif.msdr)
           wait(vif.msdr.BVALID)
              vif.msdr.BREADY<=1'b0;
$display("msdr-ended-wresp");
endtask

task master_driver::rdata(axi_xtn xtn);
//@(vif.msdr);
//vif.msdr.RREADY<=1'b1;
 int mem[int];
         $display("rdata-start");
         xtn.cal_raddr();
         xtn.strb_rcal();
           for(int i=0;i<(xtn.ARLEN+1);i++)
                 begin
                      vif.msdr.RREADY<=1;
                      @(vif.msdr);
                      wait(vif.msdr.RVALID)
                                         //mem[xtn.raddr[i]]=vif.msdr.RDATA;
                                 if(xtn.RSTRB[i]==15)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA;

                                 if(xtn.RSTRB[i]==8)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[31:24];

                                  if(xtn.RSTRB[i]==4)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[23:16];

                                  if(xtn.RSTRB[i]==2)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[15:8];

                                  if(xtn.RSTRB[i]==1)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[7:0];

                                  if(xtn.RSTRB[i]==7)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[23:0];

                                  if(xtn.RSTRB[i]==14)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[31:8];

                                  if(xtn.RSTRB[i]==12)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[31:16];

                                  if(xtn.RSTRB[i]==3)
                                         mem[xtn.raddr[i]]=vif.msdr.RDATA[15:0];
                     //input RID,RDATA,RRESP,RLAST,RVALID,RREADY;
                           vif.msdr.RREADY<=1'b0;
                         //repeat($urandom_range(1,5))
                          @(vif.msdr);
                   end
             $displayh("master received address:%p",xtn.raddr);
             $displayh("memory received in master driver is %p",mem);
$display("rdata-ended");
endtask

task master_driver::raddr(axi_xtn xtn);
$display("raddr-start");
@(vif.msdr);
vif.msdr.ARVALID<=1'b1;
vif.msdr.ARID<=xtn.ARID;
vif.msdr.ARADDR<=xtn.ARADDR;
vif.msdr.ARLEN<=xtn.ARLEN;
vif.msdr.ARSIZE<=xtn.ARSIZE;
vif.msdr.ARBURST<=xtn.ARBURST;
q4.push_back(xtn);
@(vif.msdr);
$display("inside raddr before wait ARREADY");
wait(vif.msdr.ARREADY)
vif.msdr.ARVALID<=1'b0;
$display("raddr-ended");
endtask

task master_driver::send_to_dut(axi_xtn xtn);
q1.push_back(req);
q2.push_back(req);
q3.push_back(req);
//q4.push_back(req);
q5.push_back(req);
fork
begin 
sem1.get(1);
waddr(q1.pop_front());
sem1.put(1);
sem2.put(1);
end

begin 
sem2.get(1);
sem3.get(1);
wdata(q2.pop_front());
sem3.put(1);
sem4.put(1);
end

begin
sem4.get(1);
sem5.get(1);
wresp(q3.pop_front());
sem5.put(1);
end

begin 
sem7.get(1);
raddr(q4.pop_front());
sem7.put(1);
sem6.put(1);
end

begin 
sem6.get(1);
sem8.get(1);
rdata(q5.pop_front());
sem8.put(1);
end
join_any
endtask*/
