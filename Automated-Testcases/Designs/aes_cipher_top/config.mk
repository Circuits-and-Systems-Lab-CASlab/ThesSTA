# Per-design configuration. Selected via DESIGN_CONFIG=Designs/aes_cipher_top/config.mk.

export PLATFORM     = asap7
export DESIGN_NAME  = aes_cipher_top

export VERILOG_FILE = $(DESIGN_DIR)/aes_cipher_top.v
export SDC_FILE     = $(DESIGN_DIR)/constraints.sdc

# initialise_floorplan -utilisation <N> -aspectratio <N>
export CORE_UTILISATION  = 70
export CORE_ASPECT_RATIO = 1
