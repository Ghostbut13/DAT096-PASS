restart -f -nowave
view signals wave
add wave clk_tb 
add wave din_tb 
add wave -radix unsigned dout_tb
add wave MAXbitor_inst/MAXvalue  
add wave MAXbitor_inst/outputvalue MAXbitor_inst/bitor_result_signal MAXbitor_inst/bitor_input_last_signal
run 1000 ns