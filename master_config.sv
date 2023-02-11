class master_config extends uvm_object;
`uvm_object_utils(master_config)
uvm_active_passive_enum is_active;
virtual axi_if vif;
extern function new(string name="master_config");
endclass

function master_config::new(string name="master_config");
super.new(name);
endfunction



