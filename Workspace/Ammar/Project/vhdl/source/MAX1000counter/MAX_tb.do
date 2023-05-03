restart -f -nowave
view signal wave


add wave  reset_tb fsync_tb clk_tb temp_array dout_tb 
add wave MAX1000_inst/current_index MAX1000_inst/present_state_signal MAX1000_inst/next_state_signal 
run 22 ms