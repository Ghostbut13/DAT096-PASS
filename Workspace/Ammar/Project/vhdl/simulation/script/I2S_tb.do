restart -f -nowave
view signal wave


add wave reset_tb   start_tb    fsync_tb  clk_output  bclk_tb   
add wave I2S_inst/present_state_signal	 I2S_inst/counter1   I2S_inst/counter2   I2S_inst/counter3    I2S_inst/counter4   
run 30 us