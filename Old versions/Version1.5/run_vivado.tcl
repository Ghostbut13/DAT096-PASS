########################################
## tcl script: TOP
## run_vivado
## author£ºweihan ; weihanga@chalmers.se


#Step 0: into dir
#cd "D:/Work\ Files/EESDQ/DAT096-PASS/Workspace/Weihan/Project/run_vivado"
set current_dir [pwd]
cd $current_dir

#Step 1: Setting
set_param general.maxThreads 32
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

#Step 2: Create Project
create_project -force -part xc7a100tcsg324-1 TOP_ADC TOP_project
set_property board_part digilentinc.com:nexys-a7-100t:part0:1.2 [current_project]
set_property target_language VHDL [current_project]

#Step 3: Adding RTL Files
add_files -scan_for_includes { ./design }  -norecurse 
add_files -fileset sources_1 [get_files *.vhdl] -force  -norecurse 
#import_files

#Step 4: Adding XDC Files
add_files -fileset constrs_1 {./constraint/ADC_DAC.xdc } -norecurse 

#Step 5: Importing IP
import_ip { ./ip/PLL_12M/PLL_12M.xci}
generate_target -force synthesis [get_files PLL_12M.xci]

#Step 6: Launch IP run
create_ip_run [get_files PLL_12M.xci]
launch_runs PLL_12M_synth_1 -jobs 32

#Step 7: Launching Synthesis and Implementation launch_runs synth_1
reset_run synth_1
launch_runs -jobs 32 synth_1
wait_on_run synth_1

reset_run impl_1
#launch_runs -jobs 8 impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 32
wait_on_run impl_1 
open_run impl_1




#write_bitstream { D:/Work\ Files/EESDQ/Version1.3/bibbb.bit }
start_gui

