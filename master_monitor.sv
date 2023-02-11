   class master_monitor extends uvm_monitor;
    `uvm_component_utils(master_monitor)

    virtual axi_if.m3 mif;
    master_config mst_cfg_h;
  
    axi_xtn xtn,xtn1,xtn2,xtn3,xtn4;
	axi_xtn q1[$],q2[$];
	semaphore sem_awdc = new();
	semaphore sem_wdrc = new();
	semaphore sem_wdc = new(1);
	semaphore sem_awc = new(1);
	semaphore sem_wrc = new(1);
	
	semaphore sem_ardc = new();
	semaphore sem_arc = new(1);
	semaphore sem_rdc = new(1);
        static int pkt_sent;	
	
	uvm_analysis_port#(axi_xtn) monitor_port;
    
    extern function new(string name = "master_monitor", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern task collect_awaddr();
	extern task collect_wdata(axi_xtn xtn);
	extern task collect_bresp();
	extern task collect_raddr();
	extern task collect_rdata(axi_xtn xtn);
    extern function void report_phase(uvm_phase phase); 
endclass: master_monitor

    function master_monitor::new(string name = "master_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void master_monitor::build_phase(uvm_phase phase);
        if(!uvm_config_db#(master_config)::get(this, "", "master_config", mst_cfg_h))
            `uvm_fatal("Master Driver", "getting config failed");
            super.build_phase(phase);
            monitor_port=new("monitor_port",this);
    endfunction

    function void master_monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mif=mst_cfg_h.vif;
    endfunction
	
    task  master_monitor::run_phase(uvm_phase phase);
       // super.run_phase(phase);
              forever
		collect_data();
    endtask
	
	task master_monitor::collect_data();
	fork
		begin
			sem_awc.get(1);
			collect_awaddr();
			sem_awdc.put(1);
			sem_awc.put(1);
		end
		
		begin
			sem_awdc.get(1);
			sem_wdc.get(1);
			collect_wdata(q1.pop_front());
			sem_wdc.put(1);
			sem_wdrc.put(1);
		end
		
		begin
			sem_wdrc.get(1);
			sem_wrc.get(1);
			collect_bresp();
			sem_wrc.put(1);
		end
		
		begin
			sem_arc.get(1);
			collect_raddr();
			sem_arc.put(1);
			sem_ardc.put(1);
		end
		
		begin
			sem_ardc.get(1);
			sem_rdc.get(1);
			collect_rdata(q2.pop_front());
			sem_rdc.put(1);
		end
    
	join_any
      endtask
	
	task master_monitor::collect_awaddr();
	    xtn=axi_xtn::type_id::create("xtn");
		wait(mif.msmon.AWVALID && mif.msmon.AWREADY)
		     xtn.AWVALID= mif.msmon.AWVALID;
		     xtn.AWADDR = mif.msmon.AWADDR;
		     xtn.AWSIZE = mif.msmon.AWSIZE;
		     xtn.AWID = mif.msmon.AWID;
		     xtn.AWLEN=mif.msmon.AWLEN;
		     xtn.AWBURST=mif.msmon.AWBURST;
                  q1.push_back(xtn);
		monitor_port.write(xtn);
                pkt_sent++;
	//	xtn.print();
                 `uvm_info("m3ITOR",$sformatf("printing from master monitor collect_awaddr \n %s", xtn.sprint()),UVM_LOW)
		@(mif.msmon);
	endtask
	
	task master_monitor::collect_wdata(axi_xtn xtn);
	xtn1=axi_xtn::type_id::create("xtn1");
	xtn1=xtn;
	xtn.cal_addr();
	xtn1.WDATA=new[xtn.AWLEN+1];
	xtn1.WSTRB=new[xtn.WDATA.size()];
		foreach(xtn1.WDATA[i])
			begin
			   wait(mif.msmon.WVALID && mif.msmon.WREADY)
			    xtn1.WSTRB[i]=mif.msmon.WSTRB;
				  if(mif.msmon.WSTRB==15)
					   xtn1.WDATA[i]=mif.msmon.WDATA;

			      if(mif.msmon.WSTRB==8)
					   xtn1.WDATA[i]=mif.msmon.WDATA[31:24];

				  if(mif.msmon.WSTRB==4)
					   xtn1.WDATA[i]=mif.msmon.WDATA[23:16];

				  if(mif.msmon.WSTRB==2)
					   xtn1.WDATA[i]=mif.msmon.WDATA[15:8];

				  if(mif.msmon.WSTRB==1)
					   xtn1.WDATA[i]=mif.msmon.WDATA[7:0];

				  if(mif.msmon.WSTRB==7)
						 xtn1.WDATA[i]=mif.msmon.WDATA[23:0];

				  if(mif.msmon.WSTRB==14)
						xtn1.WDATA[i]=mif.msmon.WDATA[31:8];

				  if(mif.msmon.WSTRB==12)
						xtn1.WDATA[i]=mif.msmon.WDATA[31:16];

				  if(mif.msmon.WSTRB==3)
						xtn1.WDATA[i]=mif.msmon.WDATA[15:0];

				xtn1.WID=mif.msmon.WID;
				xtn1.WLAST=mif.msmon.WLAST;
                                xtn1.WVALID=mif.msmon.WVALID;
				@(mif.msmon);
			end
		       monitor_port.write(xtn1);
                       pkt_sent++;
                       `uvm_info("m3ITOR",$sformatf("printing from master monitor collect_wdata \n %s", xtn1.sprint()),UVM_LOW)
			//xtn1.print();
	endtask
	
	task master_monitor::collect_bresp();
	     xtn2=axi_xtn::type_id::create("xtn2");
	     wait(mif.msmon.BREADY && mif.msmon.BVALID)
		 xtn2.BRESP=mif.msmon.BRESP;
		 monitor_port.write(xtn2);
	         //xtn2.print();
                 pkt_sent++;
                 `uvm_info("m3ITOR",$sformatf("printing from master monitor collect_bresp \n %s", xtn2.sprint()),UVM_LOW)
		 @(mif.msmon);
	endtask
	
	task master_monitor::collect_raddr();
	    xtn3=axi_xtn::type_id::create("xtn3");
		wait(mif.msmon.ARVALID && mif.msmon.ARREADY)
		     xtn3.ARVALID= mif.msmon.ARVALID;
		     xtn3.ARADDR = mif.msmon.ARADDR;
		     xtn3.ARSIZE = mif.msmon.ARSIZE;
		     xtn3.ARID = mif.msmon.ARID;
		     xtn3.ARLEN=mif.msmon.ARLEN;
		     xtn3.ARBURST=mif.msmon.ARBURST;
                     q2.push_back(xtn3);
		@(mif.msmon);
		monitor_port.write(xtn3);
                pkt_sent++;
	       // xtn3.print();
               `uvm_info("m3ITOR",$sformatf("printing from master monitor collect_raddr \n %s", xtn3.sprint()),UVM_LOW)
	endtask
	
	task master_monitor::collect_rdata(axi_xtn xtn);
		xtn4=axi_xtn::type_id::create("xtn4");
		xtn4=xtn;
		xtn4.cal_raddr();
		xtn4.RDATA=new[xtn.ARLEN+1];
		xtn4.RSTRB=new[xtn.RDATA.size()];
		xtn4.strb_rcal();
		foreach(xtn4.RDATA[i])
			begin
			   wait(mif.msmon.RVALID && mif.msmon.RREADY)
		              xtn4.RRESP[i] = mif.msmon.RRESP;
			      if(xtn4.RSTRB[i]==15)
			         begin
                                    xtn4.RDATA[i]=mif.msmon.RDATA;
                                 end
					 
			      if(xtn4.RSTRB[i]==8)
                                 begin
			             xtn4.RDATA[i] = mif.msmon.RDATA[31:24];
                                 end
					 
			      if(xtn4.RSTRB[i]==4)
			         begin
			             xtn4.RDATA[i]=mif.msmon.RDATA[23:16];
                                 end
					 
			      if(xtn4.RSTRB[i]==2)
			         begin
				     xtn4.RDATA[i]=mif.msmon.RDATA[15:8];
                                 end
					 
			      if(xtn4.RSTRB[i]==1)
				 begin
				     xtn4.RDATA[i]=mif.msmon.RDATA[7:0];
                                 end
					 
			      if(xtn4.RSTRB[i]==7)
				 begin
				     xtn4.RDATA[i]=mif.msmon.RDATA[23:0];
                                 end
					 
		              if(xtn4.RSTRB[i]==14)
				 begin
				     xtn4.RDATA[i]=mif.msmon.RDATA[31:8];
                                 end
					 
			      if(xtn4.RSTRB[i]==12)
				 begin
				     xtn4.RDATA[i]=mif.msmon.RDATA[31:16];
                                 end
					 
			      if(xtn4.RSTRB[i]==3)
				 begin
				     xtn4.RDATA[i]=mif.msmon.RDATA[15:0];
			         end
					 
			      xtn4.RID=mif.msmon.RID;
			      xtn4.RLAST=mif.msmon.RLAST;
                              xtn4.RVALID=mif.msmon.RVALID;
			      @(mif.msmon);
			end
			monitor_port.write(xtn4);
                        pkt_sent++;
                       `uvm_info("m3ITOR",$sformatf("printing from master monitor monitor_rdata \n %s", xtn4.sprint()),UVM_LOW)
		//	xtn4.print();
	endtask


        function void master_monitor::report_phase(uvm_phase phase); 
            `uvm_info("MASTER MONITOR",$sformatf("no of packet sent are:%0d",pkt_sent),UVM_LOW);
        endfunction


/*class master_monitor extends uvm_monitor;
`uvm_component_utils(master_monitor)
virtual axi_if.m3 vif;
axi_config m_cfg;
axi_xtn xtn,xtn1,xtn2,xtn3,xtn4;
axi_xtn q1[$],q3[$];
master_config ms_cfg;
semaphore sem1=new(1);
semaphore sem2=new();
semaphore sem3=new(1);
semaphore sem4=new();
semaphore sem5=new(1);
semaphore sem6=new();
semaphore sem7=new(1);
semaphore sem8=new(1);

static int pkt_sent;	

uvm_analysis_port #(axi_xtn) monitor_port;

extern function new(string name="master_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

extern task collect_();
extern task run_phase(uvm_phase phase);
//extern task send_to_dut(axi_xtn xtn);
extern task waddr();
extern task wdata(axi_xtn xtn);
extern task wresp();
extern task rdata(axi_xtn xtn);
extern task raddr();

endclass

function master_monitor::new(string name="master_monitor",uvm_component parent);
super.new(name,parent);
monitor_port=new("monitor_port",this);
endfunction

function void master_monitor::build_phase(uvm_phase phase);
uvm_config_db #(axi_config)::get(this,"","axi_config",m_cfg);
super.build_phase(phase);
endfunction

function void master_monitor::connect_phase(uvm_phase phase);
super.connect_phase(phase);
vif=m_cfg.ms_cfg[0].vif;
endfunction

task master_monitor::run_phase(uvm_phase phase);
forever
collect_();
endtask

task master_monitor::waddr();
xtn=axi_xtn::type_id::create("xtn");
wait(vif.msmon.AWVALID && vif.msmon.AWREADY)
//wait(vif.sldr.AWVALID)
xtn.AWVALID=vif.msmon.AWVALID;
xtn.AWADDR=vif.msmon.AWADDR;
xtn.AWID=vif.msmon.AWID;
xtn.AWLEN=vif.msmon.AWLEN;
xtn.AWBURST=vif.msmon.AWBURST;
xtn.AWSIZE=vif.msmon.AWSIZE;
q1.push_back(xtn);
monitor_port.write(xtn);
pkt_sent++;
//vif.sldr.AWREADY<=1'b0;
@(vif.msmon);
endtask

task master_monitor::wdata(axi_xtn xtn);
xtn1=axi_xtn::type_id::create("xtn1");
xtn1=xtn;
xtn.cal_addr();
xtn1.WDATA=new[xtn.AWLEN+1];
	xtn1.WSTRB=new[xtn.WDATA.size()];
		foreach(xtn1.WDATA[i])
			begin
			   wait(vif.msmon.WVALID && vif.msmon.WREADY)
			    xtn1.WSTRB[i]=vif.msmon.WSTRB;
				  if(vif.msmon.WSTRB==15)
					   xtn1.WDATA[i]=vif.msmon.WDATA;

			      if(vif.msmon.WSTRB==8)
					   xtn1.WDATA[i]=vif.msmon.WDATA[31:24];

				  if(vif.msmon.WSTRB==4)
					   xtn1.WDATA[i]=vif.msmon.WDATA[23:16];

				  if(vif.msmon.WSTRB==2)
					   xtn1.WDATA[i]=vif.msmon.WDATA[15:8];

				  if(vif.msmon.WSTRB==1)
					   xtn1.WDATA[i]=vif.msmon.WDATA[7:0];

				  if(vif.msmon.WSTRB==7)
						 xtn1.WDATA[i]=vif.msmon.WDATA[23:0];

				  if(vif.msmon.WSTRB==14)
						xtn1.WDATA[i]=vif.msmon.WDATA[31:8];

				  if(vif.msmon.WSTRB==12)
						xtn1.WDATA[i]=vif.msmon.WDATA[31:16];

				  if(vif.msmon.WSTRB==3)
						xtn1.WDATA[i]=vif.msmon.WDATA[15:0];

				xtn1.WID=vif.msmon.WID;
				xtn1.WLAST=vif.msmon.WLAST;
                                xtn1.WVALID=vif.msmon.WVALID;
				@(vif.msmon);
			end
		       monitor_port.write(xtn1);
                       pkt_sent++;
                       `uvm_info("m3ITOR",$sformatf("printing from master monitor collect_wdata \n %s", xtn1.sprint()),UVM_LOW)
			//xtn1.print();
endtask

task master_monitor::wresp();
xtn2=axi_xtn::type_id::create("xtn2");
	     wait(vif.msmon.BREADY && vif.msmon.BVALID)
		 xtn2.BRESP=vif.msmon.BRESP;
		 monitor_port.write(xtn2);
	         //xtn2.print();
                 pkt_sent++;
                 `uvm_info("m3ITOR",$sformatf("printing from master monitor collect_bresp \n %s", xtn2.sprint()),UVM_LOW)
		 @(vif.msmon);
endtask

task master_monitor::raddr();
xtn3=axi_xtn::type_id::create("xtn3");
		wait(vif.msmon.ARVALID && vif.msmon.ARREADY)
		     xtn3.ARVALID= vif.msmon.ARVALID;
		     xtn3.ARADDR = vif.msmon.ARADDR;
		     xtn3.ARSIZE = vif.msmon.ARSIZE;
		     xtn3.ARID = vif.msmon.ARID;
		     xtn3.ARLEN=vif.msmon.ARLEN;
		     xtn3.ARBURST=vif.msmon.ARBURST;
                     q3.push_back(xtn3);
		@(vif.msmon);
		monitor_port.write(xtn3);
                pkt_sent++;
	       // xtn3.print();
               `uvm_info("m3ITOR",$sformatf("printing from master monitor collect_raddr \n %s", xtn3.sprint()),UVM_LOW)
endtask

task master_monitor::rdata(axi_xtn xtn);
xtn4=axi_xtn::type_id::create("xtn4");
		xtn4=xtn;
		xtn4.cal_raddr();
		xtn4.RDATA=new[xtn.ARLEN+1];
		xtn4.RSTRB=new[xtn.RDATA.size()];
		xtn4.strb_rcal();
		foreach(xtn4.RDATA[i])
			begin
			   wait(vif.msmon.RVALID && vif.msmon.RREADY)
		              xtn4.RRESP[i] = vif.msmon.RRESP;
			      if(xtn4.RSTRB[i]==15)
			         begin
                                    xtn4.RDATA[i]=vif.msmon.RDATA;
                                 end
					 
			      if(xtn4.RSTRB[i]==8)
                                 begin
			             xtn4.RDATA[i] = vif.msmon.RDATA[31:24];
                                 end
					 
			      if(xtn4.RSTRB[i]==4)
			         begin
			             xtn4.RDATA[i]=vif.msmon.RDATA[23:16];
                                 end
					 
			      if(xtn4.RSTRB[i]==2)
			         begin
				     xtn4.RDATA[i]=vif.msmon.RDATA[15:8];
                                 end
					 
			      if(xtn4.RSTRB[i]==1)
				 begin
				     xtn4.RDATA[i]=vif.msmon.RDATA[7:0];
                                 end
					 
			      if(xtn4.RSTRB[i]==7)
				 begin
				     xtn4.RDATA[i]=vif.msmon.RDATA[23:0];
                                 end
					 
		              if(xtn4.RSTRB[i]==14)
				 begin
				     xtn4.RDATA[i]=vif.msmon.RDATA[31:8];
                                 end
					 
			      if(xtn4.RSTRB[i]==12)
				 begin
				     xtn4.RDATA[i]=vif.msmon.RDATA[31:16];
                                 end
					 
			      if(xtn4.RSTRB[i]==3)
				 begin
				     xtn4.RDATA[i]=vif.msmon.RDATA[15:0];
			         end
					 
			      xtn4.RID=vif.msmon.RID;
			      xtn4.RLAST=vif.msmon.RLAST;
                              xtn4.RVALID=vif.msmon.RVALID;
			      @(vif.msmon);
			end
			monitor_port.write(xtn4);
                        pkt_sent++;
                       `uvm_info("m3ITOR",$sformatf("printing from master monitor monitor_rdata \n %s", xtn4.sprint()),UVM_LOW)
		//	xtn4.print();
endtask

task master_monitor::collect_();
fork
begin 
sem1.get(1);
waddr();
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
wresp();
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

function void master_monitor::report_phase(uvm_phase phase);
`uvm_info("MASTER MONITOR",$sformatf("no of packet sent are:%0d",pkt_sent),UVM_LOW);
endfunction*/
