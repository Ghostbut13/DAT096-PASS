#sample_clock.do
restart -f -nowave
view signals wave
add wave clk resetn sample_count_signal sample_en PERIOD_constant
#system clock
force clk 0 0, 1 5ns -repeat 10ns
force resetn 1
run 12ns
#12 ns
force resetn 0
run 10ns
#22 ns
force resetn 1
run 290ns
#312 ns
force resetn 0
run 10ns
#322 ns
force resetn 1
run 28ns
#250 ns
