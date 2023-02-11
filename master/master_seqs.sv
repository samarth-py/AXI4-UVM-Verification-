class master_seqs extends uvm_sequence #(axi_xtn);

      `uvm_object_utils(master_seqs)
 
       extern function new(string name = "master_seqs");

endclass

       function master_seqs::new(string name = "master_seqs");
                 super.new(name);
       endfunction

//--------------------------------------------------------------------


class master_seqs1 extends master_seqs;

      `uvm_object_utils(master_seqs1)
 
       extern function new(string name = "master_seqs1");
       extern task body();

endclass

       function master_seqs1::new(string name = "master_seqs1");
                 super.new(name);
       endfunction

       task master_seqs1::body();

               req=axi_xtn::type_id::create("req");
               start_item(req);
               assert(req.randomize()with{AWBURST==0;ARBURST==0;});
               finish_item(req);
       endtask

//----------------------------------------------------------------------

class master_seqs2 extends master_seqs;

      `uvm_object_utils(master_seqs2)
 
       extern function new(string name = "master_seqs2");
       extern task body();

endclass

       function master_seqs2::new(string name = "master_seqs2");
                 super.new(name);
       endfunction

       task master_seqs2::body();

               req=axi_xtn::type_id::create("req");
               start_item(req);
               assert(req.randomize()with{AWBURST==1;ARBURST==1;});
               finish_item(req);
       endtask

//-----------------------------------------------------------------------


class master_seqs3 extends master_seqs;

      `uvm_object_utils(master_seqs3)
 
       extern function new(string name = "master_seqs3");
       extern task body();

endclass

       function master_seqs3::new(string name = "master_seqs3");
                 super.new(name);
       endfunction

       task master_seqs3::body();

               req=axi_xtn::type_id::create("req");
               start_item(req);
               assert(req.randomize()with{AWBURST==2;ARBURST==2;});
               finish_item(req);
       endtask
//----------------------------------------------------------------------------------
class master_seqs4 extends master_seqs;
`uvm_object_utils(master_seqs4);

    extern function new(string name="master_seqs4");
    extern task body();
endclass

    function master_seqs4::new(string name = "master_seqs4");
        super.new(name);
    endfunction

    task master_seqs4::body();
		repeat(50)
			begin
				req = axi_xtn::type_id::create("req");
				start_item(req);
				assert(req.randomize())
				finish_item(req);
			end 
		 repeat(50)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize()with{AWSIZE==0;ARSIZE==0;})
                                finish_item(req);
                        end
		repeat(50)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize()with{AWSIZE==1;ARSIZE==1;})
                                finish_item(req);
                        end

		repeat(50)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize()with{AWSIZE==2;ARSIZE==2;})
                                finish_item(req);
                        end


    endtask

class master_seqs5 extends master_seqs;
`uvm_object_utils(master_seqs5);

    extern function new(string name="master_seqs5");
    extern task body();
endclass

    function master_seqs5::new(string name = "master_seqs5");
        super.new(name);
    endfunction

    task master_seqs5::body();
                repeat(10)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize() with {ARSIZE==1;})
                                finish_item(req);
                        end
    endtask


/*
class master_base_sequence extends uvm_sequence #(axi_xtn);

    `uvm_object_utils(master_base_sequence);

    extern function new(string name="master_base_sequence");

endclass : master_base_sequence

    function master_base_sequence::new(string name="master_base_sequence");
        super.new(name);
    endfunction : new

class master_seq_fixed extends master_base_sequence;
`uvm_object_utils(master_seq_fixed);

    extern function new(string name="master_seq_fixed");
    extern task body();
endclass

    function master_seq_fixed::new(string name = "master_seq_fixed");
        super.new(name);
    endfunction

    task master_seq_fixed::body();
	     repeat(50)
			begin
				req = axi_xtn::type_id::create("req");
				start_item(req);
				assert(req.randomize()with{AWBURST==0;ARBURST==0;})
				finish_item(req);
			end 
    endtask
	
class master_seq_incr extends master_base_sequence;
`uvm_object_utils(master_seq_incr);

    extern function new(string name="master_seq_incr");
    extern task body();
endclass

    function master_seq_incr::new(string name = "master_seq_incr");
        super.new(name);
    endfunction

    task master_seq_incr::body();
	        repeat(50)
			begin
				req = axi_xtn::type_id::create("req");
				start_item(req);
				assert(req.randomize()with{AWBURST==1;ARBURST==1;})
				finish_item(req);
			end 
    endtask
	
class master_seq_wrap extends master_base_sequence;
`uvm_object_utils(master_seq_wrap);

    extern function new(string name="master_seq_wrap");
    extern task body();
endclass

    function master_seq_wrap::new(string name = "master_seq_wrap");
        super.new(name);
    endfunction

    task master_seq_wrap::body();
		repeat(50)
			begin
				req = axi_xtn::type_id::create("req");
				start_item(req);
				assert(req.randomize()with{AWBURST==2;ARBURST==2;})
				finish_item(req);
			end 
    endtask

class master_seq_random extends master_base_sequence;
`uvm_object_utils(master_seq_random);

    extern function new(string name="master_seq_random");
    extern task body();
endclass

    function master_seq_random::new(string name = "master_seq_random");
        super.new(name);
    endfunction

    task master_seq_random::body();
		repeat(50)
			begin
				req = axi_xtn::type_id::create("req");
				start_item(req);
				assert(req.randomize())
				finish_item(req);
			end 
		 repeat(50)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize()with{AWSIZE==0;ARSIZE==0;})
                                finish_item(req);
                        end
		repeat(50)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize()with{AWSIZE==1;ARSIZE==1;})
                                finish_item(req);
                        end

		repeat(50)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize()with{AWSIZE==2;ARSIZE==2;})
                                finish_item(req);
                        end


    endtask

class master_seq_rsize2 extends master_base_sequence;
`uvm_object_utils(master_seq_rsize2);

    extern function new(string name="master_seq_rsize2");
    extern task body();
endclass

    function master_seq_rsize2::new(string name = "master_seq_rsize2");
        super.new(name);
    endfunction

    task master_seq_rsize2::body();
                repeat(10)
                        begin
                                req = axi_xtn::type_id::create("req");
                                start_item(req);
                                assert(req.randomize() with {ARSIZE==1;})
                                finish_item(req);
                        end
    endtask

*/

