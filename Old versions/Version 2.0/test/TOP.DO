restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


# clk and rstn
add wave clk_tb rstn_tb 
# I2C to ADC
add wave SCL_tb
add wave SDA_tb
# ready
add wave SHDNZ_pin_tb 
add wave SW_vdd_ok_tb

# config state
add wave inst_W/inst_ACFC/state
add wave inst_W/inst_ACFC/next_state
# cnt
add wave -radix decimal inst_W/inst_ACFC/cnt_clk


# mode choose
add wave I2S_mode_tb 
add wave GPIO_MCLK_tb 
add wave master_mode_tb 
add wave FS_48k_256_BCLK_tb 

# mode check
add wave -radix decimal inst_W/inst_ACFC/cnt_single_config_i2c
add wave inst_W/inst_ACFC/d2_I2S_mode
add wave inst_W/inst_ACFC/d1_I2S_mode

add wave inst_W/inst_ACFC/edge_I2S_mode
add wave inst_W/inst_ACFC/edge_master_mode
add wave inst_W/inst_ACFC/edge_GPIO_MCLK
add wave inst_W/inst_ACFC/edge_FS_48k_256_BCLK

add wave inst_W/inst_ACFC/d2_GPIO_MCLK
add wave inst_W/inst_ACFC/d2_master_mode
add wave inst_W/inst_ACFC/d2_FS_48k_256_BCLK
add wave inst_W/inst_ACFC/flag_stop_single_config
add wave inst_W/inst_ACFC/OUT_config_value
add wave inst_W/inst_ACFC/OUT_config_addr 
add wave inst_W/inst_ACFC/done
add wave inst_W/inst_ACFC/OUT_start

add wave finish_config_input_tb







add wave FSYNC_tb          
add wave BCLK_tb             
add wave DIN_tb    
add wave start_I2S_tb 
add wave L1_out_tb  



add wave inst_W/inst_i2S/L1_out_signal
add wave inst_W/inst_i2S/convert_type/L1_out_signal_not
add wave inst_W/inst_i2S/convert_type/L1_UNSIGNED_1
add wave inst_W/inst_i2S/convert_type/L1_UNSIGNED_2
add wave inst_W/inst_i2S/convert_type/L1_SIGNED_1
add wave inst_W/inst_i2S/convert_type/L1_SIGNED_2
add wave inst_W/inst_i2S/L1_out_signal_converter 


run 120000000 ns