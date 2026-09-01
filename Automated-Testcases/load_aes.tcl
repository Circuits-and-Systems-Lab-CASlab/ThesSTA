# Quick standalone loader for aes_cipher_top. Drops you at the LibreEDA
# prompt. Needs a real terminal attached (no -qamode).
#
#   cd Automated-Testcases
#   /path/to/your/build/LibreEDA -no_gui -f load_aes.tcl

set PDK PDK/ASAP7
set DESIGN Designs/aes_cipher_top

load_lef "$PDK/techlef_misc/asap7_tech_4x_201209.lef $PDK/LEF/scaled/asap7sc7p5t_28_R_4x_220121a.lef $PDK/LEF/scaled/asap7sc7p5t_28_L_4x_220121a.lef $PDK/LEF/scaled/asap7sc7p5t_28_SL_4x_220121a.lef $PDK/LEF/scaled/asap7sc7p5t_28_SRAM_4x_220121a.lef"

load_lib [list [glob "$PDK/LIB/NLDM/*_TT_nldm_*.lib"]] -errors

load_verilog "$DESIGN/aes_cipher_top.v"

load_def "$DESIGN/aes_cipher_top.def" -fillrows -forcecoordinates

proc set_wire_load_mode {args} {}
proc set_clock_gating_check {args} {}
source "$DESIGN/constraints.sdc"

puts "INFO: aes_cipher_top loaded. Try: get_ports {key\[7\]}"
