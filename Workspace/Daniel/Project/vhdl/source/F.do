restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


# clk
add wave CLK_TB

# 
add wave SampleIn_TB
add wave SampleOut_TB 
add wave Indexer_TB      
add wave RefIndex_TB
add wave Multi_TB 

run 10ms

