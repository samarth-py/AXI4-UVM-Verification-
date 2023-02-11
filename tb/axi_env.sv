class axi_env extends uvm_env;
`uvm_component_utils(axi_env)
master_agent_top m_agt;
slave_agent_top sl_agt;
axi_scoreboard sb;
axi_config m_cfg;
axi_sequencer v_seqr;
extern function new(string name="axi_env",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass

function axi_env::new(string name="axi_env",uvm_component parent);
super.new(name,parent);
endfunction

function void axi_env::build_phase(uvm_phase phase);
        if(!uvm_config_db#(axi_config)::get(this,"","axi_config",m_cfg))
            `uvm_fatal("AXI Env","Unable to get axi env config, have you set it in test?")
    
        if(m_cfg.has_master_agent_top)
            begin
              foreach(m_cfg.ms_cfg[i])
                uvm_config_db#(master_config)::set(this,"m_agt*","master_config",m_cfg.ms_cfg[i]);
                m_agt=master_agent_top::type_id::create("m_agt",this);
	    end

        if(m_cfg.has_slave_agent_top)
            begin
              foreach(m_cfg.sl_cfg[i])
                uvm_config_db#(slave_config)::set(this,"sl_agt*","slave_config",m_cfg.sl_cfg[i]);
                sl_agt=slave_agent_top::type_id::create("sl_agt",this);
            end

        if(m_cfg.has_virtual_sequencer)
            begin
            v_seqr=axi_sequencer::type_id::create("v_seqr",this);
            end
        if(m_cfg.has_scoreboard)
            sb=axi_scoreboard::type_id::create("sb",this);
        super.build_phase(phase);
    endfunction

function void axi_env::connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(m_cfg.has_virtual_sequencer)
begin
foreach(v_seqr.mst_seqrh[i])
 v_seqr.mst_seqrh[i]=m_agt.ma[i].seqh;
foreach(v_seqr.slv_seqrh[i])
 v_seqr.slv_seqrh[i]=sl_agt.sla[i].slv_seqr_h;
end

if(m_cfg.has_scoreboard)
begin
foreach(m_agt.ma[i])
m_agt.ma[i].monh.monitor_port.connect(sb.mst_fifo_h[i].analysis_export);
foreach(sl_agt.sla[i])
  sl_agt.sla[i].slv_mon_h.slave_port.connect(sb.slv_fifo_h[i].analysis_export);
end
endfunction
