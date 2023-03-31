vlib work
#vlog ../src/ddr2.v ./tb_ddr2.v ./ddr2_model.v ./clk_wiz_0_sim_netlist.v ./mig_7series_0_sim_netlist.v ./glbl.v



vcom D:/Work\ Files/EESDQ/DAT096-PASS/Workspace/Weihan/Project/vhdl/source/ddr/ddr2.vhdl 
vlog D:/Work\ Files/EESDQ/DAT096-PASS/Workspace/Weihan/Project/vhdl/simulation/sim/ddr/tb_ddr2.v 
vlog D:/Work\ Files/EESDQ/DAT096-PASS/Workspace/Weihan/Project/vhdl/simulation/sim/ddr/ddr2_model.v 
vlog D:/Work\ Files/EESDQ/DAT096-PASS/Workspace/Weihan/Project/vhdl/simulation/sim/ddr/clk_wiz_0_sim_netlist.v 
vlog D:/Work\ Files/EESDQ/DAT096-PASS/Workspace/Weihan/Project/vhdl/simulation/sim/ddr/mig_7series_0_sim_netlist.v 
vlog D:/Work\ Files/EESDQ/DAT096-PASS/Workspace/Weihan/Project/vhdl/simulation/sim/ddr/glbl.v


#vsim -L xpm -L secureip -L unisims_ver -L unimacro_ver -L unifast_ver -L simprims_ver work.tb_ddr2 work.glbl -voptargs=+acc +notimingchecks
vsim work.tb_ddr2 work.glbl -voptargs=+acc +notimingchecks
log -depth 7 /*
do wave.do
run 2ms
