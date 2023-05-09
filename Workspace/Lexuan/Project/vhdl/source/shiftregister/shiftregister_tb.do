restart -f -nowave
view signals wave
add wave clk_fsync_tb clk_bclk_tb dout_PE_tb dout_xcorr_tb
add wave shiftregister_inst/din
--add wave shiftregister_inst/addr_write
add wave -radix unsigned shiftregister_inst/addr_read
--add wave shiftregister_inst/read_en
add wave shiftregister_inst/dout_xcorr_signal
add wave shiftregister_inst/dout_PE_signal
add wave shiftregister_inst/dout_xcorr
add wave shiftregister_inst/dout_PE
add wave -radix unsigned shiftregister_inst/counter
add wave shiftregister_inst/data_read
add wave shiftregister_inst/BRAM_inst/RAM
run 1 ms