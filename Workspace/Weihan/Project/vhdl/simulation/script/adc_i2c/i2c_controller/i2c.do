restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear



add wave clk_tb rstn_tb 
add wave inst/state
add wave inst/next_state
add wave SCL_tb
add wave SDA_tb
add wave inst/clk_scl

add wave -radix decimal inst/cnt_clk
add wave start_tb
add wave inst/flag_sent inst/flag_stop_scl

run 1200000 ns