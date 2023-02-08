restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


# clk and reset_n
add wave clk_tb rstn_tb 
# state
add wave inst/state
add wave inst/next_state
# important SW signal
add wave SW_vdd_ok_tb 
add wave SHDNZ_pin_tb
# when launch/terminate cnt
add wave inst/flag_cnt_STOP 
add wave inst/flag_cnt_START
# how long to wait between some steps
add wave -radix decimal inst/cnt_clk
add wave -radix decimal inst/waiting_time
# when launch/terminate I2C
add wave start_tb
add wave done_tb



add wave inst/OUT_config_value




run 26000000 ns