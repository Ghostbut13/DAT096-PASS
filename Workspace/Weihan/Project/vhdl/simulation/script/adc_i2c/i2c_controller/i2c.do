vsim -voptargs="+acc" work.i2c_master_tb(arch_i2c_master_tb) 
restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear



add wave clk_tb rstn_tb 
add wave inst/state
add wave inst/next_state
add wave SCL_tb
add wave SDA_tb
add wave inst/clk_scl

add wave -radix decimal inst/cnt_clk
add wave start_tb
add wave inst/flag_sent 
add wave inst/flag_TURN_OFF_I2C
add wave inst/flag_TURN_ON_I2C_T


add wave inst/flag_TURN_OFF_I2C_after5us
add wave -radix decimal inst/cnt_delay5us
add wave inst/flag_delayT_busbuf_5us

add wave inst/edge_on
add wave inst/edge_off

add wave inst/addr_config
add wave inst/data_config

run 2400000 ns