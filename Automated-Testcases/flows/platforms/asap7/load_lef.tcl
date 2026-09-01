# LEF only (tech + all cell-row flavors), no Liberty -- enough for
# placement-only flows. Uses the 4x-scaled macro LEFs since only the 4x
# tech LEF is present in this PDK checkout (mixing 1x macros with a 4x
# tech LEF misaligns geometry). PDK_ROOT defaults to ./PDK.

if {[info exists env(PDK_ROOT)]} {
  set PDK_ROOT $env(PDK_ROOT)
} else {
  set PDK_ROOT PDK
}
set ASAP7 "$PDK_ROOT/ASAP7"

load_lef "$ASAP7/techlef_misc/asap7_tech_4x_201209.lef $ASAP7/LEF/scaled/asap7sc7p5t_28_R_4x_220121a.lef $ASAP7/LEF/scaled/asap7sc7p5t_28_L_4x_220121a.lef $ASAP7/LEF/scaled/asap7sc7p5t_28_SL_4x_220121a.lef $ASAP7/LEF/scaled/asap7sc7p5t_28_SRAM_4x_220121a.lef"
