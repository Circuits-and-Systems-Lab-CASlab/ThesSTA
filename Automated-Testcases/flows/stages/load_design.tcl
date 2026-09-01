# Loads the netlist and, if Liberty was loaded this session, sources the
# SDC too. Requires load_lef.tcl to have already run. Expects VERILOG_FILE
# / SDC_FILE / LOAD_LIB in the environment (set by the Makefile).

load_verilog $env(VERILOG_FILE)

# Without a timing library LibreEDA has no time unit to scale against, so
# create_clock reports garbage (-period 1.0 comes back as 1e9). Skip the
# SDC entirely when LOAD_LIB=0 instead of sourcing it for a meaningless result.
if {[info exists env(LOAD_LIB)] && $env(LOAD_LIB) == "1"} {
  # set_wire_load_mode / set_clock_gating_check are unimplemented stubs that
  # abort under -qamode; shadow as no-ops so constraints.sdc can be sourced
  # unmodified.
  proc set_wire_load_mode {args} {}
  proc set_clock_gating_check {args} {}

  source $env(SDC_FILE)
} else {
  puts "INFO: No Liberty loaded this session -- skipping $env(SDC_FILE)."
}
