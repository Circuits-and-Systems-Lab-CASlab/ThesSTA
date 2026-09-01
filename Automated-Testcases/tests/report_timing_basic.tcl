# Regression test: full STA flow (clock + I/O delays + report_timing) on a
# minimal 2-cell design (in -> INV1 -> BUF1 -> out). Checks the tool still
# produces the expected timing report/slack for a known-good design.
set DATA $env(TESTCASE_DATA)

load_lef "$DATA/mini.lef"
load_lib "$DATA/mini.lib" -errors
load_verilog "$DATA/mini.v"

set clk_name clk
set clock_period 1.0
create_clock $clk_name -period $clock_period -name $clk_name

set_input_delay 0.0 -clock $clk_name [all_inputs]
set_output_delay 0.0 -clock $clk_name [all_outputs]

report_timing -corner 0 -longest -backannotate

puts "TEST: report_timing_basic OK"
exit
