# Per-design configuration. Selected via DESIGN_CONFIG=Designs/aes_sky130hs/config.mk.
# Same aes_cipher_top RTL as Designs/aes_cipher_top, synthesized against
# sky130hs instead of ASAP7 (via a Yosys synthesis run).

export PLATFORM     = sky130hs
export DESIGN_NAME  = aes_cipher_top

export VERILOG_FILE = $(DESIGN_DIR)/aes_cipher_top.v
export SDC_FILE     = $(DESIGN_DIR)/constraints.sdc

# initialise_floorplan -utilisation <N> -aspectratio <N>
export CORE_UTILISATION  = 40
export CORE_ASPECT_RATIO = 1
