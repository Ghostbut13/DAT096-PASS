restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear



add wave clk_tb rstn_tb 
add wave inst/state
add wave inst/next_state

add wave SW_vdd_ok_tb SHDNZ_pin_tb
add wave inst/SW_vdd_ok
add wave inst/flag_cnt_STOP inst/flag_cnt_START


add wave -radix decimal inst/cnt_clk
add wave -radix decimal inst/waiting_time

add wave start_tb
add wave done_tb


run 12000000 ns