restart -f -nowave
view signals wave
add wave clk_tb 
add wave din1_tb din2_tb din3_tb din4_tb
add wave dout_loudest_tb dout_secondloudest_tb dout_thirdloudest_tb
run 100 ns