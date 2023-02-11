class axi_xtn extends uvm_sequence_item;
    `uvm_object_utils(axi_xtn);

        bit ARESETn;
        rand bit [3:0] AWID;
        rand bit [31:0] AWADDR;
        rand bit [7:0] AWLEN;
        rand bit [2:0] AWSIZE;
        rand bit [1:0] AWBURST;
       //logic AWVALID;
       logic AWREADY;
        bit AWVALID;

        //Declaration of Write Data Channel Signals
        rand bit [3:0] WID;
        rand bit [31:0] WDATA[];
        bit [3:0] WSTRB[];
        logic WLAST;
        logic WVALID;
        logic WREADY;

        //Declaration of Write Response Channel Signals
        rand bit [3:0] BID;
        bit [1:0] BRESP;
        logic BVALID;
        logic BREADY;

        rand bit [3:0] ARID;
        rand bit [31:0] ARADDR;
        rand bit [7:0] ARLEN;
        rand bit [2:0] ARSIZE;
        rand bit [1:0] ARBURST;
        //logic ARVALID;
        logic ARREADY;
        bit ARVALID;

        rand bit [3:0] RID;
        rand bit [31:0] RDATA[];
        bit[1:0] RRESP[];
        logic RLAST;
        logic RREADY;
        logic RVALID;

        bit [31:0]addr[];
        int no_bytes;
        int aligned_addr;
        int start_addr;


        /**********Read************/
        bit [3:0]RSTRB[];
        bit [31:0]raddr[];
        int no_rbytes;
        int aligned_raddr;
        int start_raddr;
        /*********************/



        constraint wdata_c                        {WDATA.size()==(AWLEN+1);}
        constraint ardata_c                        {RDATA.size()==(ARLEN+1);}
        constraint awb                            {AWBURST dist{0:=10,1:=10,2:=10};}
	constraint arb                            {ARBURST dist{0:=10,1:=10,2:=10};}
        //constraint arb                            {ARBURST inside {[0:2]};}
        constraint write_id_c                     {AWID == WID; BID==WID;}
        constraint read_id_c                      {RID == ARID;}
        constraint aws_c                          {AWSIZE dist{0:=10,1:=10,2:=10};}
        constraint ars_c                          {ARSIZE dist{0:=10,1:=10,2:=10};}
      // constraint aws_c1                         {AWBURST==1;}

      // constraint ars_c1                         {ARBURST==1;}
        constraint awl_c                          {if(AWBURST==2)  (AWLEN+1) inside {2,4,8,16};}
        constraint arl_c                          {if(ARBURST==2)  (ARLEN+1) inside {2,4,8,16};}
        constraint write_alignmnent_c1            {((AWBURST == 2'b10 || AWBURST == 2'b00) && AWSIZE == 1) -> AWADDR%2 == 0;} //alignment for wrap
        constraint write_alignmnent_c2            {((AWBURST == 2'b10 || AWBURST == 2'b00) && AWSIZE == 2) -> AWADDR%4 == 0;}
        constraint read_alignmnent_c1             {((ARBURST == 2'b10 || ARBURST == 2'b00) && ARSIZE == 1) -> ARADDR%2 == 0;} //alignment for wrap
        constraint read_alignmnent_c2             {((ARBURST == 2'b10 || ARBURST == 2'b00) && ARSIZE == 2) -> ARADDR%4 == 0;}
        constraint max_boundary_c                  {(2**AWSIZE)*(AWLEN+1)<4096;}
        constraint max_boundary_cr                  {(2**ARSIZE)*(ARLEN+1)<4096;}

        constraint awlent_c                         {AWLEN inside {[1:17]};}
        constraint arlent_c                         {ARLEN inside {[1:17]};}

        extern function new(string name = "axi_xtn");
        extern function void do_print(uvm_printer printer);
        extern function bit do_compare(uvm_object rhs,uvm_comparer comparer);
        extern function void post_randomize();
        extern function void cal_addr();
        extern function void strb_cal();
        extern function void cal_raddr();
        extern function void strb_rcal();
endclass:axi_xtn


        function axi_xtn::new(string name = "axi_xtn");
                super.new(name);
        endfunction:new


        function void axi_xtn::post_randomize();
           no_bytes=2**AWSIZE;
           aligned_addr= (int'(AWADDR/no_bytes))*no_bytes;
           start_addr=AWADDR;
           WSTRB=new[AWLEN+1];

           /*********for read*************/
           no_rbytes=2**ARSIZE;
           aligned_raddr= (int'(ARADDR/no_rbytes))*no_rbytes;
           start_raddr=ARADDR;
           RSTRB=new[ARLEN+1];
           /**********************/
           cal_addr();
           strb_cal();
                   cal_raddr();
        endfunction

/*****************************************************************************************************/
        function void axi_xtn::cal_addr();
            bit wb;
            int burst_len=AWLEN+1;
                int N=burst_len;
                int wrap_boundary=(int'(AWADDR/(no_bytes*burst_len)))*(no_bytes*burst_len);
                int addr_n=wrap_boundary+(no_bytes*burst_len);
                addr=new[AWLEN+1];
                addr[0]=AWADDR;

               /*********************/
                no_bytes=2**AWSIZE;
                aligned_addr= (int'(AWADDR/no_bytes))*no_bytes;
                start_addr=AWADDR;
              /*********************/

                for(int i=2;i<(burst_len+1);i++)
                   begin
                      if(AWBURST==0)
                           addr[i-1]=AWADDR;

                      if(AWBURST==1)
                           begin
                               addr[i-1]=aligned_addr+(i-1)*no_bytes;
                           end

                      if(AWBURST==2)
                           begin
                               if(wb==0)
                                   begin
                                       addr[i-1]=aligned_addr+(i-1)*no_bytes;
                                       if(addr[i-1]==(wrap_boundary+(no_bytes*burst_len)))
                                       begin
                                           addr[i-1]=wrap_boundary;
                                           wb++;
                                       end
                                   end

                               else
                                   addr[i-1]=start_addr+((i-1)*no_bytes)-(no_bytes*burst_len);
                           end
                  end
        endfunction

        function void axi_xtn::strb_cal();
        int data_bus_bytes=4;
        int lower_byte_lane,upper_byte_lane;


        int lower_byte_lane_0=start_addr-((int'(start_addr/data_bus_bytes))*data_bus_bytes);
        int upper_byte_lane_0=(aligned_addr+(no_bytes-1))-((int'(start_addr/data_bus_bytes))*data_bus_bytes);


        for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
        begin
                WSTRB[0][j]=1;
        end


        for(int i=1;i<(AWLEN+1);i++)
                begin
                                lower_byte_lane=addr[i]-(int'(addr[i]/data_bus_bytes))*data_bus_bytes;
                                        upper_byte_lane=lower_byte_lane+no_bytes-1;
                                        for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
                                                WSTRB[i][j]=1;
            end
        endfunction

/************************************************************************************************************/

/*************************************************Read Calculations******************************************/
                  function void axi_xtn::cal_raddr();
            bit wb;
            int burst_len=ARLEN+1;
                int N=burst_len;
                int wrap_boundary=(int'(ARADDR/(no_rbytes*burst_len)))*(no_rbytes*burst_len);
                int raddr_n=wrap_boundary+(no_rbytes*burst_len);
                raddr=new[ARLEN+1];
                raddr[0]=ARADDR;

               /*********************/
                no_rbytes=2**ARSIZE;
                aligned_raddr= (int'(ARADDR/no_rbytes))*no_rbytes;
                start_raddr=ARADDR;
              /*********************/

                for(int i=2;i<(burst_len+1);i++)
                   begin
                      if(ARBURST==0)
                           raddr[i-1]=ARADDR;

                      if(ARBURST==1)
                           begin
                               raddr[i-1]=aligned_raddr+(i-1)*no_rbytes;
                           end

                      if(ARBURST==2)
                           begin
                               if(wb==0)
                                   begin
                                       raddr[i-1]=aligned_raddr+(i-1)*no_rbytes;
                                       if(raddr[i-1]==(wrap_boundary+(no_rbytes*burst_len)))
                                       begin
                                           raddr[i-1]=wrap_boundary;
                                           wb++;
                                       end
                                   end

                               else
                                   raddr[i-1]=start_raddr+((i-1)*no_rbytes)-(no_rbytes*burst_len);
                           end
                  end
        endfunction

        function void axi_xtn::strb_rcal();
        int data_bus_bytes=4;
        int lower_byte_lane,upper_byte_lane;


        int lower_byte_lane_0=start_raddr-((int'(start_raddr/data_bus_bytes))*data_bus_bytes);
        int upper_byte_lane_0=(aligned_raddr+(no_rbytes-1))-((int'(start_raddr/data_bus_bytes))*data_bus_bytes);


        for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
        begin
                RSTRB[0][j]=1;
        end


        for(int i=1;i<(ARLEN+1);i++)
                begin
                                lower_byte_lane=raddr[i]-(int'(raddr[i]/data_bus_bytes))*data_bus_bytes;
                                        upper_byte_lane=lower_byte_lane+no_rbytes-1;
                                        for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
                                                RSTRB[i][j]=1;
            end
        endfunction

/************************************************************************************************************/

/****************************************Print Method**********************************************************/

         function void  axi_xtn::do_print (uvm_printer printer);
                super.do_print(printer);

                //write address channel
                //                   starting name          bitstream value     size       radix for printing
                printer.print_field( "AWID",                this.AWID,         04,          UVM_DEC);
                printer.print_field( "AWADDR",              this.AWADDR,       32,          UVM_HEX);
                printer.print_field( "AWLEN",               this.AWLEN,        04,          UVM_DEC);
                printer.print_field( "AWSIZE",              this.AWSIZE,       03,          UVM_DEC);
                printer.print_field( "AWBURST",             this.AWBURST,      02,          UVM_DEC);

                //write data channel
                //                   starting name          bitstream value     size             radix for printing
                printer.print_field( "WID",                this.WID,         04,           UVM_DEC);
                foreach(this.WDATA[i])
                    begin
                printer.print_field( "WDATA",              this.WDATA[i],    32 ,  UVM_HEX);
                printer.print_field( "WSTRB",              this.WSTRB[i],     4,            UVM_BIN);
                printer.print_field( "WLAST",              this.WLAST,        1,            UVM_DEC);
                    end

                //Write Response Channel
                //                   starting name          bitstream value     size             radix for printing
                printer.print_field( "BID",                this.BID,           04,           UVM_DEC);
                printer.print_field( "BRESP",              this.BRESP,         02,           UVM_DEC);


                //read address channel
                //                   starting name          bitstream value     size       radix for printing
                printer.print_field( "ARID",                this.ARID,         04,          UVM_DEC);
                printer.print_field( "ARADDR",              this.ARADDR,       32,          UVM_HEX);
                printer.print_field( "ARLEN",               this.ARLEN,        08,          UVM_DEC);
                printer.print_field( "ARSIZE",              this.ARSIZE,       03,          UVM_DEC);
                printer.print_field( "ARBURST",             this.ARBURST,      02,          UVM_DEC);

                //read data channel
                //                   starting name          bitstream value     size             radix for printing
                printer.print_field( "RID",                this.RID,           04,           UVM_DEC);
                foreach(this.RDATA[i])
                    begin
                printer.print_field( "RDATA",              this.RDATA[i],     32,     UVM_HEX);
                printer.print_field( "RRESP",              this.RRESP[i],       02,            UVM_DEC);
                    end

         endfunction:do_print

/********************************************************************************************************************/

/****************************************Compare_Method**********************************************************/
function bit axi_xtn::do_compare (uvm_object rhs,uvm_comparer comparer);
     axi_xtn rhs_;
    if(!$cast(rhs_,rhs))
                begin
                 `uvm_fatal("do_compare","failed")
                  return 0;
                end
         // `uvm_info("AXI XTN",$sformatf("printing rhs_ xtn from axi_xtn\n %s", rhs_.sprint()),UVM_LOW)
         // `uvm_info("AXI XTN",$sformatf("printing this xtn from axi_xtn\n %s", this.sprint()),UVM_LOW)
          
         return super.do_compare(rhs,comparer) &&
        AWID==rhs_.AWID  &&
        AWADDR==rhs_.AWADDR &&
        AWLEN==rhs_.AWLEN &&
        AWSIZE==rhs_.AWSIZE &&
        AWBURST==rhs_.AWBURST &&

        WID==rhs_.WID &&
        //foreach(WDATA[i])
       // begin
        WDATA==rhs_.WDATA &&
        WSTRB==rhs_.WSTRB &&
	//end

        //Declaration of Write Response Channel Signals
        BID==rhs_.BID &&
        BRESP==rhs_.BRESP &&

        ARID==rhs_.ARID  &&
        ARADDR==rhs_.ARADDR &&
        ARLEN==rhs_.ARLEN &&
        ARSIZE==rhs_.ARSIZE &&
        ARBURST==rhs_.ARBURST &&

        RID==rhs_.RID &&
        //foreach(RDATA[i])
       // begin
        RDATA==rhs_.RDATA &&
        RRESP==rhs_.RRESP;
	//end

endfunction

