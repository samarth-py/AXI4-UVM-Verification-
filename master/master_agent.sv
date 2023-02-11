class master_agent extends uvm_agent;
`uvm_component_utils(master_agent)
master_monitor monh;
master_driver drih;
master_sequencer seqh;
master_config ms_cfg;
extern function new(string name="master_agent",uvm_component parent=null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase);
endclass

function master_agent::new(string name="master_agent",uvm_component parent=null);
super.new(name,parent);
endfunction

function void master_agent::build_phase(uvm_phase phase);
uvm_config_db #(master_config)::get(this,"","master_config",ms_cfg);
super.build_phase(phase);
monh=master_monitor::type_id::create("monh",this);
if(ms_cfg.is_active==UVM_ACTIVE)
begin
drih=master_driver::type_id::create("drih",this);
seqh=master_sequencer::type_id::create("seqh",this);
end
endfunction

function void master_agent::connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(ms_cfg.is_active==UVM_ACTIVE)
begin
drih.seq_item_port.connect(seqh.seq_item_export);
end
endfunction
