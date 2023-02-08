#SPI_DA.do
restart -f -nowave
view signals wave
add wave resetn clk send DA_channel DA_gain DA_data
add wave SDI_DA CS_DA
add wave SCLK_enable
force clk 0 0, 1 10ns -repeat 20ns
force SCLK_enable 1 0,0 20ns -repeat 500ns
force resetn 1
force send 0
force DA_channel 1
force DA_gain 0
run 125 ns
#reset
force resetn 0
#force DA_data 12'b101010101010
force DA_data 12'b101111001110
run 200ns
force resetn 1
run 200ns
force send 1
run 600ns
force send 0
run 10000ns