-------------------------------
-- MAC_gen_min_12_101_tb3.do --
-- do file for running       --
-- testbench type 3 for      --
-- multiply/accumulate (MAC) --
-- direct implementation     --
-- using GENERATE            --
-- 12 bit signal             --
-- 12 bit coefficients       --
-- 17 taps                   --
-- mini version              --
-- Sven Knutsson             --
-------------------------------

restart -f -nowave
view signals wave
add wave clk_tb_signal resetn_tb_signal x_tb_signal start_tb_signal
add wave y_tb_signal -radix decimal y_tb_signal -radix binary y_tb_signal
run 250000ns
