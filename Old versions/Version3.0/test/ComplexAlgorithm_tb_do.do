restart -f -nowave
view signal wave

--add wave rstn_tb   clk_sysclk_tb_signal  clk_fsync_tb_signal
--add wave LC1_tb LC2_tb RC1_tb RC2_tb
run 370536 us
