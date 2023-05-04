restart -f -nowave
view signals wave
add wave clk_tb 
add wave din_c1_tb din_c2_tb
add wave din_xcorr1_tb din_xcorr2_tb
add wave dout_tb
add wave Xcorr_inst/dout
run 1100 ns