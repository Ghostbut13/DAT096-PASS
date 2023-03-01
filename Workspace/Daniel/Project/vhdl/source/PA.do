restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


# clk
add wave clk_tb

# 
add wave TargetIndex_TB      
add wave Indexer_TB      

run 1300ms

