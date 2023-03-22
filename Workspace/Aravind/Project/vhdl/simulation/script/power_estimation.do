restart -f -nowave
add wave clk_tb shiftregister_inst/reset_n
add wave din_tb dout_tb clk_tb counter
add wave -decimal shiftregister_inst/power_data shiftregister_inst/data shiftregister_inst/dout
add wave -decimal shiftregister_inst/dout_sig

add wave -decimal shiftregister_inst/power_estimation_inst/abs_power -decimal shiftregister_inst/power_estimation_inst/power_data_sig  
add wave -decimal shiftregister_inst/power_estimation_inst/old_data_abs -decimal shiftregister_inst/power_estimation_inst/new_data_abs

run 500ns
