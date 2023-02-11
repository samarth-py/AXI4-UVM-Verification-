class slave_seqs extends uvm_sequence #(axi_xtn);

      `uvm_object_utils(slave_seqs)
 
       extern function new(string name = "slave_seqs");

endclass

       function slave_seqs::new(string name = "slave_seqs");
                 super.new(name);
       endfunction

//--------------------------------------------------------------------


class slave_seqs1 extends slave_seqs;

      `uvm_object_utils(slave_seqs1)
 
       extern function new(string name = "slave_seqs1");
       extern task body();

endclass

       function slave_seqs1::new(string name = "slave_seqs1");
                 super.new(name);
       endfunction

       task slave_seqs1::body();

               req=axi_xtn::type_id::create("req");
               start_item(req);
               assert(req.randomize());
               finish_item(req);
       endtask  
