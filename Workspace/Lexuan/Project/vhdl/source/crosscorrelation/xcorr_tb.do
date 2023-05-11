restart -f -nowave
view signals wave
add wave clk_fsync_tb clk_bclk_tb
add wave din_1_tb din_2_tb dout_tb
add wave dout_PE_1_tb dout_PE_2_tb
add wave dout_index_tb xcorr_output
add wave dout_xcorr_lag_1_tb dout_xcorr_lag_2_tb
add wave dout_xcorr_ref_1_tb dout_xcorr_ref_2_tb
add wave shiftregister_channel1_inst/addr_read
add wave shiftregister_channel1_inst/addr_write
add wave shiftregister_channel1_inst/counter
run 416 ms