# Liberty, TT corner, NLDM (not CCS -- CCS is ~300MB/file vs ~20MB for
# NLDM), all Vt flavors merged into one corner. Only needed for
# timing-aware flows; this is the slowest part of loading the PDK (~5-6s).
# Requires load_lef.tcl to have run first.

if {[info exists env(PDK_ROOT)]} {
  set PDK_ROOT $env(PDK_ROOT)
} else {
  set PDK_ROOT PDK
}
set ASAP7 "$PDK_ROOT/ASAP7"

# load_lib wants a list of corners (each a list of files); a flat list
# would make every file its own corner. Upstream ships each cell group's
# TT-corner Liberty as its own file, corner embedded in the filename
# (asap7sc7p5t_<group>_<vt>_TT_nldm_<date>.lib) rather than in a per-corner
# subdirectory -- see fetch_asap7_pdk.sh, which fetches exactly these.
load_lib [list [glob "$ASAP7/LIB/NLDM/*_TT_nldm_*.lib"]] -errors
