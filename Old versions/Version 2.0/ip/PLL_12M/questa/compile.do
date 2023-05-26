vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../version_2.0.gen/sources_1/bd/PLL_12M/ipshared/7698" \
"C:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../version_2.0.gen/sources_1/bd/PLL_12M/ipshared/7698" \
"../../../bd/PLL_12M/ip/PLL_12M_clk_wiz_0_0/PLL_12M_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/PLL_12M/ip/PLL_12M_clk_wiz_0_0/PLL_12M_clk_wiz_0_0.v" \

vcom -work xil_defaultlib  -93  \
"../../../bd/PLL_12M/sim/PLL_12M.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

