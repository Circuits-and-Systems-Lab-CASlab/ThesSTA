# Liberty, TT corner (25C, 1.8V) -- the only corner vendored here. Requires
# load_lef.tcl to have run first in this session.

if {[info exists env(PDK_ROOT)]} {
  set PDK_ROOT $env(PDK_ROOT)
} else {
  set PDK_ROOT PDK
}
set SKY130HS "$PDK_ROOT/sky130hs"

load_lib [list [glob "$SKY130HS/lib/*.lib"]] -errors
