restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


# clk
add wave CLK_TB

# 
add wave rst_n_tb		din_tb		xy_pos_in_tb		xy_pos_out_tb  
add wave inst_maxLUT/CURRENT_MAX
run 100us

