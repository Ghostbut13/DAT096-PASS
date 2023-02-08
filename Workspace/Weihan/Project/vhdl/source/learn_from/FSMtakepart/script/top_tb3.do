----------------------------------------
-- SPI_state_tb3.do                   --
-- do file to run the                 --
-- Test bench to simulate a           --
-- state version of SPI configuration --
-- of a MicroChip MCP4822 DAC         --
-- The test bench requires a special  --
-- version of SPI_state.vhdl called   --
-- SPI_state_tb.vhdl so the states    --
-- can be monitored                   --
-- Sven Knutsson                      --
----------------------------------------

restart -f -nowave
view signals wave
add wave reset_tb3_signal clk_tb3_signal start_tb3_signal
add wave SPI_clk_enable_tb3_signal A_B_tb3_signal GA_tb3_signal
add wave D_tb3_signal CS_tb3_signal SDI_tb3_signal
--add wave state_tb3_signal next_state_tb3_signal



add wave top_inst_1/fsm2_inst_1/fsm1_done
add wave top_inst_1/fsm2_inst_1/fsm1_s
add wave top_inst_1/fsm2_inst_1/fsm1_load 
add wave top_inst_1/fsm2_inst_1/fsm1_start
add wave top_inst_1/fsm2_inst_1/state
add wave top_inst_1/fsm2_inst_1/next_state

add wave top_inst_1/fsm1_inst_1/empty_flag 
add wave top_inst_1/fsm1_inst_1/state
add wave top_inst_1/fsm1_inst_1/next_state
add wave top_inst_1/fsm1_inst_1/cnt_out

run 9800ns
