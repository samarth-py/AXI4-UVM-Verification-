class axi_config extends uvm_object;
`uvm_object_utils(axi_config)
bit has_scoreboard=1;
bit has_functional_coverage=1;
bit has_slave_agent_top= 1;
bit has_master_agent_top= 1;
int no_of_master=1;
int no_of_slave=1;
bit has_virtual_sequencer = 1;
master_config ms_cfg[];
slave_config sl_cfg[];
extern function new(string name="axi_config");
endclass

function axi_config::new(string name="axi_config");
super.new(name);
endfunction
