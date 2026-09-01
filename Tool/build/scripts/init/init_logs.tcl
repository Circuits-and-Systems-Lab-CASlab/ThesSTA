# Generated Date: 2026-09-01 18:25:32
set __LibreEDA_filename ""

# puts "LibreEDA_LOGS_PREFIX: $::env(LibreEDA_LOGS_PREFIX)"
# puts "LibreEDA_OVERWRITE_LOGS: $::env(LibreEDA_OVERWRITE_LOGS)"

set __LibreEDA_filename $::env(LibreEDA_CMD_FILE)


set __LibreEDA_log_file [open $__LibreEDA_filename "a"]
puts $__LibreEDA_log_file ""
close $__LibreEDA_log_file

proc logCommand {__LibreEDA_command op} {
    global __LibreEDA_filename
    set __LibreEDA_log_file [open $__LibreEDA_filename "a"]

    if {[string match "*__LibreEDA_*" $__LibreEDA_command] || [string match "*puts file*" $__LibreEDA_command]} {
      close $__LibreEDA_log_file
      return
    }

    if {[string match "^source*" $__LibreEDA_command]} {
      puts $__LibreEDA_log_file "source ${__LibreEDA_command}"
    }

    puts $__LibreEDA_log_file $__LibreEDA_command
    close $__LibreEDA_log_file
}

set allCommands [info commands]

# Set up a trace on each command
foreach cmd $allCommands {

    # skip commands: trace, if, proc, logCommand, open, close, string, continue, break, return, info
    if {$cmd eq "trace" || $cmd eq "if" || $cmd eq "proc" || $cmd eq "logCommand" || $cmd eq "open" || $cmd eq "close" || $cmd eq "string" || $cmd eq "continue" || $cmd eq "break" || $cmd eq "return" || $cmd eq "info"} {
        continue
    }

    trace add execution $cmd enter logCommand
}
