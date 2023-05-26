restart -f -nowave
view signal wave

add wave rstn_tb clk_tb_signal LC1_tb LC2_tb RC1_tb RC2_tb OUTPUT_tb INDEX_OUT_tb PA_INDEXER_tb
add wave SA_inst/dout_sa_signal SA_inst/power_out_sa_signal SA_inst/MaxIndexer_sa_signal SA_inst/PAIndexer_sa_signal
add wave   SA_inst/FaderMultiOut_sa_signal SA_inst/FaderMultiOut_sa_signal
--force rstn_tb 1 0ns, 0 3ns, 1 13ns

run 1 sec
