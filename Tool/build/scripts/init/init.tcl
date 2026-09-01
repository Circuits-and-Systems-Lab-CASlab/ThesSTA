# Generated Date: 2026-09-01 18:25:32
# Initialize the TCL environment except if $::env(NO_CMD) is set to 1
if {[info exists ::env(LibreEDA_NO_CMD)] && $::env(LibreEDA_NO_CMD) != 1} {
  source $::env(LibreEDA_ROOT_DIR)/scripts/init/init_logs.tcl
}


# run set_max_threads if $::env(LibreEDA_THREADS) is set and greater than 1
if {[info exists ::env(LibreEDA_THREADS)] && $::env(LibreEDA_THREADS) > 1} {
    set_max_threads $::env(LibreEDA_THREADS)
}
