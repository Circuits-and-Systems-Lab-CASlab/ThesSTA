# Tech LEF + merged standard-cell LEF for sky130hs (SkyWater 130nm, high-speed
# cell library). Sufficient for placement-only flows; no Liberty here.

if {[info exists env(PDK_ROOT)]} {
  set PDK_ROOT $env(PDK_ROOT)
} else {
  set PDK_ROOT PDK
}
set SKY130HS "$PDK_ROOT/sky130hs"

load_lef "$SKY130HS/lef/sky130_fd_sc_hs.tlef $SKY130HS/lef/sky130_fd_sc_hs_merged.lef"
