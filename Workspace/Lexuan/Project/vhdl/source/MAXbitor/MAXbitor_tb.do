restart -f -nowave
view signals wave
add wave clk_tb 
add wave din_tb dout_tb
add wave MAXbitor_inst/MAXvalue  MAXbitor_inst/outputvalue MAXbitor_inst/bitor_result_signal
run 1000 ns