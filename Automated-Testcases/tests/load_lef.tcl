# Smoke test: load a minimal synthetic LEF and confirm it parses cleanly.
set DATA $env(TESTCASE_DATA)

load_lef "$DATA/mini.lef"
puts "TEST: load_lef OK"
exit
