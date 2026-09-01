# Requires floorplan.tcl to have already run. GP_TIMING_DRIVEN=1
# (Makefile: TIMING_DRIVEN=1) needs load_lib.tcl composed in too.

if {[info exists env(GP_TIMING_DRIVEN)] && $env(GP_TIMING_DRIVEN) == "1"} {
  global_place -solver 4 -gradient 3 -timing_driven
} else {
  global_place -solver 4 -gradient 3
}
