#SPI_AD.do
restart -f -nowave
view signals wave
add wave resetn clk SCLK_enable ODD_SIGN receive AD_receive/bitcount_variable
add wave CS_AD DIN_AD DOUT_AD DATA_valid_AD AD_data AD_data_signal
force clk 0 0, 1 10ns -repeat 20ns
force SCLK_enable 1 0,0 20ns -repeat 600ns
force resetn 1
force ODD_SIGN 0
force receive 0
run 25ns
force resetn 0
force clk 0 0, 1 10ns -repeat 20ns
force resetn 1
force receive 0
run 125 ns
#reset
force resetn 0
force DOUT_AD 0
run 200ns
force resetn 1
run 400ns
#receive from AD
#insignal 0100 1110 1001
force receive 1
#0 in
run 4000ns
force receive 0
#1 in
force DOUT_AD 1 
run 600ns
force DOUT_AD 0
#00 in
run 1200ns
force DOUT_AD 1
#111 in
run 1800ns
force DOUT_AD 0
#0 in
run 600ns
force DOUT_AD 1
#1 in
run 600ns
force DOUT_AD 0
#00 in
run 1200ns
force DOUT_AD 1
#11 in
run 2000ns