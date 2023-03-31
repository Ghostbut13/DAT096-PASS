restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


add wave clk_tb   rstn_tb  start_tb 
add wave inst1/fsync

add wave inst1/tcp1/state 
add wave inst1/tcp1/next_state inst1/tcp1/CLKIN

add wave inst1/tcp1/channel_1 inst1/tcp1/channel_2 inst1/tcp1/channel_3 inst1/tcp1/channel_4 


add wave inst1/tcp1/CRSDV_MODE2
    add wave inst1/tcp1/RXD1_MODE1      
    add wave inst1/tcp1/RXD0_MODE0        
    add wave inst1/tcp1/RXERR_PHYAD0    
    add wave inst1/tcp1/TXD0            
    add wave inst1/tcp1/TXD1             
    add wave inst1/tcp1/txen      
add wave inst1/tcp1/channel_feet_2
     add wave inst1/tcp1/channel_feet_1   

add wave -radix decimal inst1/tcp1/cnt_32

add wave -radix decimal inst1/tcp1/cnt_write_round

add wave inst1/tcp1/o_TXD_1 
add wave inst1/tcp1/o_TXD_0            


############################################
##check componets
add wave inst1/tcp1/crc_start
add wave inst1/tcp1/channel_test
#add wave inst1/tcp1/CRC
add wave inst1/tcp1/CRC_new
#add wave inst1/tcp1/inst_CRC/R_CRC_RES
#add wave inst1/tcp1/inst_CRC/O_CRC_RES
add wave inst1/tcp1/IP_HEAD_CHECK_SUM
add wave inst1/tcp1/inst_IP_CHECK/O_IP_HEAD_CHECK_SUM

run 1610000 ns


