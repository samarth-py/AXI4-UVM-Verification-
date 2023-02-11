class master_agent_top extends uvm_env;
`uvm_component_utils(master_agent_top)
master_agent ma[];
master_config ms_cfg[];
axi_config m_cfg;
extern function new(string name="master_agent_top",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);
endclass

function master_agent_top::new(string name="master_agent_top",uvm_component parent);
super.new(name,parent);
endfunction

function void master_agent_top::build_phase(uvm_phase phase);
uvm_config_db#(axi_config)::get(this,"","axi_config",m_cfg);
ma=new[m_cfg.no_of_master];
ms_cfg=new[m_cfg.no_of_master];
foreach (ma[i]) begin
ms_cfg[i]=m_cfg.ms_cfg[i];
uvm_config_db #(master_config)::set(this,$sformatf("ma[%0d]*",i),"master_config",m_cfg.ms_cfg[i]);
ma[i]=master_agent::type_id::create($sformatf("ma[%0d]",i),this);
end
super.build_phase(phase);
endfunction

function void master_agent_top::report_phase(uvm_phase phase);
uvm_top.print_topology();
endfunction
