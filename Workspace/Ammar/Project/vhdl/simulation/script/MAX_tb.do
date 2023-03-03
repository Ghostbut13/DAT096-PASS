restart -f -nowave
view signal wave


add wave  reset_tb clk_tb   DIN1_tb    DIN2_tb    DIN3_tb    DIN4_tb  done_tb   max_tb  
add wave MAX_inst/current_max
run 100 ms