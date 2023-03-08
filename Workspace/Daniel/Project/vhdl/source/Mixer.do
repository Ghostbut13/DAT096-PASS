restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


# clk
add wave CLK_TB

# 
add wave Input1_TB
add wave Input2_TB
add wave Input3_TB
add wave Input4_TB
add wave Output_TB

run 1ms
