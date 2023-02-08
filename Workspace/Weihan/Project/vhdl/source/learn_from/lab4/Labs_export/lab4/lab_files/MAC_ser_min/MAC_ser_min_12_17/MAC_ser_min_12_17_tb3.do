----------------------------------
-- MAC_ser_min_12_17_tb3.do     --
-- do file for running          --
-- testbench type 3 for         --
-- multiplier/accumulator (MAC) --
-- serial implementation        --
-- 12 bit signal                --
-- 12 bit coefficients          --
-- 17 taps                      --
-- mini version                 --
-- Sven Knutsson                --
----------------------------------

restart -f -nowave
view signals wave
add wave clk_tb_signal resetn_tb_signal x_tb_signal start_tb_signal
#add wave MAC_ser_min_12_17_comp/x_array_signal
#add wave MAC_ser_min_12_17_comp/x_array_signal(0)
add wave y_tb_signal finished_tb_signal -radix decimal y_tb_signal
add wave -radix binary y_tb_signal
run 43000ns
