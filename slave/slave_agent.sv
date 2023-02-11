class slave_agent extends uvm_agent;

        `uvm_component_utils(slave_agent)

    extern function new(string name="slave_agent",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

    slave_driver slv_drv_h;
    slave_monitor slv_mon_h;
    slave_sequencer slv_seqr_h;
    slave_config slv_cfg_h;
 endclass



     function slave_agent::new(string name ="slave_agent", uvm_component parent);
         super.new(name,parent);
     endfunction


     function void slave_agent::build_phase(uvm_phase phase);

         if(!uvm_config_db #(slave_config)::get(this," ","slave_config",slv_cfg_h))
             `uvm_fatal("slave_agent","no response from config, have you set it in env")

         slv_mon_h=slave_monitor::type_id::create("slv_mon_h",this);

                 if(slv_cfg_h.is_active==UVM_ACTIVE)
             begin
                 slv_drv_h=slave_driver::type_id::create("slv_drv_h",this);
                 slv_seqr_h=slave_sequencer::type_id::create("slv_seqr_h",this);
             end

         super.build_phase(phase);
    endfunction

    function void slave_agent::connect_phase(uvm_phase phase);
        if(slv_cfg_h.is_active==UVM_ACTIVE)
            begin
                slv_drv_h.seq_item_port.connect(slv_seqr_h.seq_item_export);
            end
        super.connect_phase(phase);
    endfunction

