@echo off










set current_dir=%cd%
vivado -mode tcl -source run_vivado.tcl "%current_dir%"

