restart -f -nowave
view signals wave
config wave -signalnamewidth 1
set NumericStdNoWarnings 1
.main clear


# clk
add wave CLK_TB
add wave mic1_tb mic2_tb mic3_tb mic4_tb 
add wave y_pos_in_tb output_tb INST_AC/distance_cm

add wave INST_AC/mic1_multiplied    INST_AC/mic2_multiplied 
add wave INST_AC/mic3_multiplied    INST_AC/mic4_multiplied
add wave INST_AC/temp1 INST_AC/temp2 INST_AC/temp3 INST_AC/temp4
# 
run 20ms

