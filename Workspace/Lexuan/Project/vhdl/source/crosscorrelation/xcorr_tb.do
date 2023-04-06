restart -f -nowave
view signals wave
add wave clk_tb 
add wave newest_data_1_tb newest_data_2_tb oldest_data_1_tb oldest_data_2_tb
add wave dout_tb
add wave XCorr_inst/xcorr XCorr_inst/shiftregister_out  XCorr_inst/dout
add wave XCorr_inst/xcorr_array/din XCorr_inst/xcorr_array/dout XCorr_inst/xcorr_array/data XCorr_inst/xcorr_array/dout_sig
run 110 ns