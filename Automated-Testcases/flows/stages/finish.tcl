# Always composed last. GUI=1 opens the GUI first; INTERACTIVE=1 drops to
# the LibreEDA prompt instead of exiting. Default: exit immediately.

if {[info exists env(GUI)] && $env(GUI) == "1"} {
  show_gui
}

if {![info exists env(INTERACTIVE)] || $env(INTERACTIVE) != "1"} {
  exit
}
