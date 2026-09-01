# Requires load_lef.tcl + load_design.tcl to have already run.
# CORE_UTILISATION / CORE_ASPECT_RATIO come from the design's config.mk.

initialise_floorplan -utilisation $env(CORE_UTILISATION) -aspectratio $env(CORE_ASPECT_RATIO)
io_place
