# Smoke test: load LEF + Liberty + a minimal synthetic Verilog netlist.
set DATA $env(TESTCASE_DATA)

load_lef "$DATA/mini.lef"
load_lib "$DATA/mini.lib" -errors
load_verilog "$DATA/mini.v"
puts "TEST: load_verilog OK"
exit
