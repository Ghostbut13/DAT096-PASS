restart -f -nowave
view signals wave
add wave clk_tb 
add wave din_tb dout_tb
add wave MAXbitor_inst/maxvalue
run 1000 ns