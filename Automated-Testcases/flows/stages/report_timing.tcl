# Requires load_lib.tcl and load_design.tcl to have already run. RC is
# placement-based instead of ideal/lumped if floorplan/global_place ran first.

report_timing -corner 0 -longest -backannotate
