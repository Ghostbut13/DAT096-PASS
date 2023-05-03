restart -f -nowave
view signal wave


add wave  reset_tb clk_tb temp_array dout_tb MAX1000_inst/current_index MAX1000_inst/present_state_signal 
--add wave MAX_inst/counter_temp
run 1000 ms