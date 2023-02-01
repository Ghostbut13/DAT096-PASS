restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear

add wave ASE_inst/clk_100ns

add wave clk_tb rstn_tb 
add wave clk_enable_tb 
add wave ASE_inst/inst_AES_R10/ciphertext_tmp 

add wave -radix decimal ASE_inst/inst_AES_R10/cnt_read_cip 
add wave ASE_inst/inst_AES_R10/uart_txd 
add wave ASE_inst/inst_AES_R10/uart_enable

add wave ASE_inst/inst_AES_R10/uart_txd_signal
add wave ASE_inst/inst_AES_R10/cnt_tx 
add wave ASE_inst/inst_AES_R10/cnt_clk
add wave ASE_inst/inst_AES_R10/data_t
add wave ASE_inst/inst_AES_R10/tx_flag
add wave ASE_inst/inst_AES_R10/buffer_reg64_1
add wave ASE_inst/inst_AES_R10/cnt_start
add wave ASE_inst/inst_AES_R10/enb
add wave -radix decimal ASE_inst/inst_AES_R10/cnt_trans_RF
add wave ASE_inst/inst_AES_R10/RX_RF
add wave ASE_inst/inst_AES_R10/TXD

--when {stop_tb_flag} {
--  stop
--  echo "Test: OK"
--}
--run -all
-- run 2290 ns
run 8333600 ns