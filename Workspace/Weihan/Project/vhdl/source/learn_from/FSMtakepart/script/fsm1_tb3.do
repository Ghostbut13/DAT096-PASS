-- do file for fsm1_tb3.  / ljs sep 13 2021 

restart -f -nowave
view signals wave
add wave din_tb clk_tb reset_tb load_tb start_tb s_tb done_tb
add wave CE_tb 
--add wave fsm1_inst/bitno fsm1_inst/data fsm1_inst/shifting
add wave counter_tb


add wave data_tb
add wave empty_flag_tb
add wave state_tb next_state_tb

run 10000ns
