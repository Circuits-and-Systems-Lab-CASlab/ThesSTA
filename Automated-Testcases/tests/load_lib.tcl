# Smoke test: load LEF + a minimal synthetic Liberty file.
set DATA $env(TESTCASE_DATA)

load_lef "$DATA/mini.lef"
load_lib "$DATA/mini.lib" -errors
puts "TEST: load_lib OK"
exit
