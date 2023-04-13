restart -f -nowave
view signals wave
add wave clk_tb 
add wave din_tb 
add wave -radix unsigned dout_tb
add wave MAXbitor_inst/bitor_inst/bitor_done
add wave MAXbitor_inst/bitor_inst/bitor_start
run 1000 ns