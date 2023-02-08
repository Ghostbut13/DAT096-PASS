-- do file for fsm2_tb3.  / weihan gao on 25 sep 

restart -f -nowave
view signals wave
add wave reset_tb3_signal clk_tb3_signal fsm2_start_tb3_signal
add wave SPI_clk_enable_tb3_signal A_B_tb3_signal GA_tb3_signal
add wave CS_tb3_signal SDI_tb3_signal
add wave state_tb3_signal next_state_tb3_signal

add wave fsm1_done_tb3_signal fsm1_empty_flag_tb3_signal fsm1_s_tb3_signal
add wave fsm1_load_tb3_signal fsm1_start_tb3_signal

run 10000ns
