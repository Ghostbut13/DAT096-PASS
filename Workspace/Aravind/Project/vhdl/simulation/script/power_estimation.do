restart -f -nowave
add wave clk_tb 
add wave -decimal test_data_tb 
add wave din_tb dout_tb clk_tb counter
add wave -decimal shiftregister_inst/power_data_tb shiftregister_inst/data shiftregister_inst/dout
add wave -decimal shiftregister_inst/dout_sig

run 500ns
