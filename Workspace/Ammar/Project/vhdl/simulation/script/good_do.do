restart -f -nowave
view signal wave
add wave reset clk go_Right go_Left shoot SEG message_out
force clk 0 0ns, 1 5ns -repeat 10ns
force reset 1 0ns, 0 9ns, 1 10ns
force SW 1 0ns
force shoot 0 0ns, 1 1ms, 0 4ms, 1 10ms, 0 14ms, 1 35ms, 0 39ms
force go_Right 1 0ns, 0 5ms, 1 7ms, 0 12ms, 1 15ms, 0 28ms, 1 32ms
force go_Left 1 0ns

run 50ms
