vlib work
vlib riviera

vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../version_2.0.gen/sources_1/bd/PLL_12M/ipshared/7698" \
"C:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  \
"C:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../version_2.0.gen/sources_1/bd/PLL_12M/ipshared/7698" \
"../../../bd/PLL_12M/ip/PLL_12M_clk_wiz_0_0/PLL_12M_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/PLL_12M/ip/PLL_12M_clk_wiz_0_0/PLL_12M_clk_wiz_0_0.v" \

vcom -work xil_defaultlib -93  \
"../../../bd/PLL_12M/sim/PLL_12M.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

