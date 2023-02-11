class axi_sequencer extends uvm_sequencer #(uvm_sequence_item);

      `uvm_component_utils(axi_sequencer)

       master_sequencer mst_seqrh[];
       slave_sequencer slv_seqrh[];

       axi_config e_cfg;

       extern function new(string name="axi_sequencer",uvm_component parent);
       extern function void build_phase(uvm_phase phase);

endclass
//----------------------------------------------------------------------

      function axi_sequencer::new(string name="axi_sequencer",uvm_component parent);
                      super.new(name,parent);
      endfunction
//--------------------------------------------------------------------------

      function void axi_sequencer::build_phase(uvm_phase phase);

	super.build_phase(phase);
	if(!uvm_config_db #(axi_config)::get(this,"","axi_config",e_cfg))
	  `uvm_fatal("CONFIG","cannot get e_cfg have you set it?")
          
        	mst_seqrh=new[e_cfg.no_of_master];
	        slv_seqrh=new[e_cfg.no_of_slave];
endfunction

