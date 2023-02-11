class slave_monitor extends uvm_monitor;
`uvm_component_utils(slave_monitor)
slave_config sl_cfg;
virtual axi_if.m4 vif;

axi_xtn xtn,xtn1,xtn2,xtn3,xtn4;
axi_xtn q1[$],q2[$];

semaphore sem1 = new();
semaphore sem2 = new();
semaphore sem3 = new(1);
semaphore sem4 = new(1);
semaphore sem5 = new(1);
semaphore sem6 = new();
semaphore sem7 = new(1);
semaphore sem8 = new(1);

axi_config m_cfg;
uvm_analysis_port #(axi_xtn) slave_port;

extern function new(string name="slave_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task collect_data();
extern task collect_awaddr();
extern task collect_wdata(axi_xtn xtn);
extern task collect_bresp();
extern task collect_raddr();
extern task collect_rdata(axi_xtn xtn);

endclass

function slave_monitor::new(string name="slave_monitor",uvm_component parent);
super.new(name,parent);
slave_port=new("monitor_port",this);
endfunction

function void slave_monitor::build_phase(uvm_phase phase);
uvm_config_db #(axi_config)::get(this,"","axi_config",m_cfg);
super.build_phase(phase);
endfunction

function void slave_monitor::connect_phase(uvm_phase phase);
vif=m_cfg.sl_cfg[0].vif;
endfunction

task  slave_monitor::run_phase(uvm_phase phase);
     // super.run_phase(phase);
     forever
       collect_data();
endtask

task slave_monitor::collect_data();
        fork
                begin
                        sem4.get(1);
                        collect_awaddr();
                        sem1.put(1);
                        sem4.put(1);
                end

                begin
                        sem1.get(1);
                        sem3.get(1);
                        collect_wdata(q1.pop_front());
                        sem3.put(1);
                        sem2.put(1);
                end

                begin
                        sem2.get(1);
                        sem5.get(1);
                        collect_bresp();
                        sem5.put(1);
                end

                begin
                        sem7.get(1);
                        collect_raddr();
                        sem7.put(1);
                        sem6.put(1);
                end

                begin
                        sem6.get(1);
                        sem8.get(1);
                        collect_rdata(q2.pop_front());
                        sem8.put(1);
                end

        join_any
      endtask

task slave_monitor::collect_awaddr();
            xtn=axi_xtn::type_id::create("xtn");
                wait(vif.slmon.AWVALID && vif.slmon.AWREADY)
                     xtn.AWVALID= vif.slmon.AWVALID;
                     xtn.AWADDR = vif.slmon.AWADDR;
                     xtn.AWSIZE = vif.slmon.AWSIZE;
                     xtn.AWID = vif.slmon.AWID;
                     xtn.AWLEN=vif.slmon.AWLEN;
                     xtn.AWBURST=vif.slmon.AWBURST;
                  q1.push_back(xtn);
                slave_port.write(xtn);
        //      xtn.print();
                 `uvm_info("slv_monitor",$sformatf("printing from slave monitor collect_awaddr \n %s", xtn.sprint()),UVM_LOW)
                @(vif.slmon);
        endtask

task slave_monitor::collect_wdata(axi_xtn xtn);
        xtn1=axi_xtn::type_id::create("xtn1");
        xtn1=xtn;
        xtn.cal_addr();
        xtn1.WDATA=new[xtn.AWLEN+1];
        xtn1.WSTRB=new[xtn.WDATA.size()];
                foreach(xtn1.WDATA[i])
                        begin
                           wait(vif.slmon.WVALID && vif.slmon.WREADY)
                            xtn1.WSTRB[i]=vif.slmon.WSTRB;
                                  if(vif.slmon.WSTRB==15)
                                           xtn1.WDATA[i]=vif.slmon.WDATA;

                              if(vif.slmon.WSTRB==8)
                                           xtn1.WDATA[i]=vif.slmon.WDATA[31:24];

                                  if(vif.slmon.WSTRB==4)
                                           xtn1.WDATA[i]=vif.slmon.WDATA[23:16];

                                  if(vif.slmon.WSTRB==2)
                                           xtn1.WDATA[i]=vif.slmon.WDATA[15:8];

                                  if(vif.slmon.WSTRB==1)
                                           xtn1.WDATA[i]=vif.slmon.WDATA[7:0];

                                  if(vif.slmon.WSTRB==7)
                                                 xtn1.WDATA[i]=vif.slmon.WDATA[23:0];

                                  if(vif.slmon.WSTRB==14)
                                                xtn1.WDATA[i]=vif.slmon.WDATA[31:8];

                                  if(vif.slmon.WSTRB==12)
                                                xtn1.WDATA[i]=vif.slmon.WDATA[31:16];

                                  if(vif.slmon.WSTRB==3)
                                                xtn1.WDATA[i]=vif.slmon.WDATA[15:0];

                                xtn1.WID=vif.slmon.WID;
                                xtn1.WLAST=vif.slmon.WLAST;
                                xtn1.WVALID=vif.slmon.WVALID;
                                @(vif.slmon);
                        end
                        slave_port.write(xtn1);
                       `uvm_info("slv_monitor",$sformatf("printing from slave monitor collect_wdata \n %s", xtn1.sprint()),UVM_LOW)
                        //xtn1.print();
        endtask

        task slave_monitor::collect_bresp();
             xtn2=axi_xtn::type_id::create("xtn2");
             wait(vif.slmon.BREADY && vif.slmon.BVALID)
                 xtn2.BRESP=vif.slmon.BRESP;
                 slave_port.write(xtn2);
                 //xtn2.print();
                 `uvm_info("slv_monitor",$sformatf("printing from slave monitor collect_bresp \n %s", xtn2.sprint()),UVM_LOW)
                 @(vif.slmon);
        endtask

        task slave_monitor::collect_raddr();
            xtn3=axi_xtn::type_id::create("xtn3");
                wait(vif.slmon.ARVALID && vif.slmon.ARREADY)
                     xtn3.ARVALID= vif.slmon.ARVALID;
                     xtn3.ARADDR = vif.slmon.ARADDR;
                     xtn3.ARSIZE = vif.slmon.ARSIZE;
                     xtn3.ARID = vif.slmon.ARID;
                     xtn3.ARLEN=vif.slmon.ARLEN;
                     xtn3.ARBURST=vif.slmon.ARBURST;
                     q2.push_back(xtn3);
                @(vif.slmon);
                slave_port.write(xtn3);
               // xtn3.print();
               `uvm_info("slv_monitor",$sformatf("printing from slave monitor collect_raddr \n %s", xtn3.sprint()),UVM_LOW)
        endtask

task slave_monitor::collect_rdata(axi_xtn xtn);
 xtn4=axi_xtn::type_id::create("xtn4");
 xtn4=xtn;
 xtn4.cal_raddr();
 xtn4.RDATA=new[xtn.ARLEN+1];
 xtn4.RSTRB=new[xtn.RDATA.size()];
 xtn4.strb_rcal();
  foreach(xtn4.RDATA[i])
     begin
       wait(vif.slmon.RVALID && vif.slmon.RREADY)
       xtn4.RRESP[i] = vif.slmon.RRESP;
       if(xtn4.RSTRB[i]==15)
         begin
          xtn4.RDATA[i]=vif.slmon.RDATA;
         end
       if(xtn4.RSTRB[i]==8)
         begin
          xtn4.RDATA[i]=vif.slmon.RDATA[31:24];
         end

       if(xtn4.RSTRB[i]==4)
         begin
          xtn4.RDATA[i]=vif.slmon.RDATA[23:16];
         end

       if(xtn4.RSTRB[i]==2)
         begin
          xtn4.RDATA[i]=vif.slmon.RDATA[15:8];
         end

       if(xtn4.RSTRB[i]==1)
          begin
           xtn4.RDATA[i]=vif.slmon.RDATA[7:0];
          end

       if(xtn4.RSTRB[i]==7)
          begin
            xtn4.RDATA[i]=vif.slmon.RDATA[23:0];
          end

       if(xtn4.RSTRB[i]==14)
          begin
            xtn4.RDATA[i]=vif.slmon.RDATA[31:8];
          end

       if(xtn4.RSTRB[i]==12)
         begin
           xtn4.RDATA[i]=vif.slmon.RDATA[31:16];
         end

      if(xtn4.RSTRB[i]==3)
        begin
          xtn4.RDATA[i]=vif.slmon.RDATA[15:0];
        end

      xtn4.RID=vif.slmon.RID;
      xtn4.RLAST=vif.slmon.RLAST;
      xtn4.RVALID=vif.slmon.RVALID;
      @(vif.slmon);
      end
 slave_port.write(xtn4);
`uvm_info("slv_monitor",$sformatf("printing from slave monitor monitor_rdata \n %s", xtn4.sprint()),UVM_LOW)
     //      xtn4.print();
endtask
