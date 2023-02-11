##Makefile for UVM Testbench
RTL= ../interface/axi_if.sv
work= work
SVTB1= ../tb/axi_top.sv
INC = +incdir+../tb +incdir+../test +incdir+../master +incdir+../slave
SVTB2 = ../test/axi_pkg.sv
VSIMOPT= -vopt -voptargs=+acc
VSIMCOV= -coverage -sva
VSIMBATCH1= -c -do  " log -r /* ;coverage save -onexit mem_cov1;run -all; exit"
VSIMBATCH2= -c -do  " log -r /* ;coverage save -onexit mem_cov2;run -all; exit"
VSIMBATCH3= -c -do  " log -r /* ;coverage save -onexit mem_cov3;run -all; exit"
VSIMBATCH4= -c -do  " log -r /* ;coverage save -onexit mem_cov4;run -all; exit"
VSIMBATCH5= -c -do  " log -r /* ;coverage save -onexit mem_cov5;run -all; exit"
VSIMBATCH6= -c -do  " log -r /* ;coverage save -onexit mem_cov6;run -all; exit"


help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                             											!"
	@echo "! clean   	=>  clean the earlier log and intermediate files.       								!"
	@echo "! sv_cmp    	=>  Create library and compile the code.                   								!"
	@echo "! run_sim    =>  run the simulation in batch mode.                   								!"
	@echo "! run_test	=>  clean, compile & run the simulation for fixed_seq_test in batch mode.		!" 
	@echo "! run_test1	=>  clean, compile & run the simulation for incr_seq_test in batch mode.			!" 
	@echo "! run_test2	=>  clean, compile & run the simulation for wrap_seq_test in batch mode.			!"
	@echo "! run_test3	=>  clean, compile & run the simulation for random_seq_test in batch mode.			!" 
	@echo "! run_test4	=>  clean, compile & run the simulation for rsize2_seq_test in batch mode.			!" 
#	@echo "! run_test5	=>  clean, compile & run the simulation for soft_reset_test in batch mode.			!" 
	@echo "! view_wave1 =>  To view the waveform of fixed_seq_test	    								!" 
	@echo "! view_wave2 =>  To view the waveform of incr_seq_test	    									!" 
	@echo "! view_wave3 =>  To view the waveform of wrap_seq_test	  	  									!" 
	@echo "! view_wave4 =>  To view the waveform of random_seq_test	    									!" 
	@echo "! view_wave5 =>  To view the waveform of rsize2_seq_test	    									!" 
#	@echo "! view_wave6 =>  To view the waveform of soft_reset_test	    									!" 
	@echo "! regress    =>  clean, compile and run all testcases in batch mode.		    						!"
	@echo "! report     =>  To merge coverage reports for all testcases and  convert to html format.			!"
	@echo "! cov        =>  To open merged coverage report in html format.										!"
	@echo ====================================================================================================================
	


sv_cmp:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1)

run_test:sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf wave_file1.wlf -l test1.log  -sv_seed random  work.axi_top +UVM_TESTNAME=axi_extd_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1

run_test1:sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2)  -wlf wave_file2.wlf -l test2.log  -sv_seed random  work.axi_top +UVM_OBJECTION_TRACE  +UVM_TESTNAME=axi_extd_test1
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2

run_test2:sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3)  -wlf wave_file3.wlf -l test3.log  -sv_seed random  work.axi_top +UVM_TESTNAME=axi_extd_test2
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov3

run_test3:sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave_file4.wlf -l test4.log  -sv_seed random  work.axi_top +UVM_TESTNAME=axi_extd_test3
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov4

run_test4:sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH5)  -wlf wave_file5.wlf -l test5.log  -sv_seed random  work.axi_top +UVM_TESTNAME=axi_extd_test4
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov5

#run_test5:sv_cmp
#	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH6)  -wlf wave_file6.wlf -l test6.log  -sv_seed random  work.top +UVM_TESTNAME=soft_reset_test
#	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov6


report:
	vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3 mem_cov4 mem_cov5 
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov

regress: clean  run_test run_test1 run_test2 run_test3 run_test4 report cov

cov:
	firefox covhtmlreport/index.html&


view_wave1:
	vsim -view wave_file1.wlf

view_wave2:
	vsim -view wave_file2.wlf

view_wave3:
	vsim -view wave_file3.wlf

view_wave4:
	vsim -view wave_file4.wlf

view_wave5:
	vsim -view wave_file5.wlf

#view_wave6:
#	vsim -view wave_file6.wlf

clean:
	rm -rf transcript* *log*  vsim.wlf fcover* covhtml* mem_cov* *.wlf modelsim.ini
	clear

