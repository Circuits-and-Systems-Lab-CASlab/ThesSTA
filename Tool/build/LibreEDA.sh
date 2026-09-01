#!/usr/bin/bash
# Generated Date: 2026-09-01 18:25:32
#
# Wrapper script for LibreEDA
# This script will have the following arguments:
# -no_gui
# -help
# -f <TCL script>
# -exit_on_error
# -threads <number of threads> (default 1, no less than 1 are allowed)
# -logs_prefix <prefix for log files> (default LibreEDA_history)
# -overwrite_logs (default false)
# -no_cmd (default false)
#
# The first two are to be given to ./LibreEDA
# The rest are to set environment variables for the script
# All environment variables are optional and start with LibreEDA_

print_help() {
  echo "Usage: LibreEDA [options]"
  echo "Options:"
  echo "  -no_gui                             Run LibreEDA without GUI"
  echo "  -help                               Print this help message"
  echo "  -f <TCL script>                     Source specified TCL script upon startup"
  echo "  -exit_on_error                      Close LibreEDA if any error occurs"
  echo "  -threads <number of threads>        Specify number of threads (default: 1, no less than 1 are allowed)"
  echo "  -logs_prefix <prefix for log files> Specify prefix for log files (default: LibreEDA_history.cmd)"
  echo "  -overwrite_logs                     Overwrite most recently created log files (default false)"
  echo "  -no_cmd                             Don't create command log files (default false)"
  echo "  -no_logs                            Don't create log files (default false)"
}

export LibreEDA_ROOT_DIR=$(dirname $(realpath $0))

# Set default values
# Number of threads
export LibreEDA_THREADS=1

# Prefix for log files
export LibreEDA_LOGS_PREFIX=$(pwd)/LibreEDA_history

# Overwrite log files
export LibreEDA_OVERWRITE_LOGS=0

# Don't print commands
export LibreEDA_NO_CMD=0

# Don't print logs
export LibreEDA_NO_LOGS=0

# Parse arguments
LibreEDA_ARGS=""

if [[ $@ == *"-no_gui"* ]]; then
    LibreEDA_ARGS="${LibreEDA_ARGS} -no_gui"
fi
if [[ $@ == *"-help"* ]]; then
  print_help
  exit 0
fi

if [[ $@ == *"-f"* ]]; then
  # get file from argument after -f
  FILENAME=$(echo $@ | sed -n 's/.*-f \([^ ]*\).*/\1/p')
  LibreEDA_ARGS="${LibreEDA_ARGS} -f ${FILENAME}"
fi

if [[ $@ == *"-exit_on_error"* ]]; then
    LibreEDA_ARGS="${LibreEDA_ARGS} -qamode"
fi

# Get number of threads
if [[ $@ == *"-threads"* ]]; then
  # get number of threads from argument after -threads
  LibreEDA_THREADS=$(echo $@ | sed -n 's/.*-threads \([^ ]*\).*/\1/p')
  if [[ $LibreEDA_THREADS -lt 1 ]]; then
    echo "Number of threads must be at least 1"
    exit 1
  fi
  export LibreEDA_THREADS
fi

# Get prefix for log files
if [[ $@ == *"-logs_prefix"* ]]; then
  # get prefix from argument after -logs_prefix
  LibreEDA_LOGS_PREFIX=$(realpath $(echo $@ | sed -n 's/.*-logs_prefix \([^ ]*\).*/\1/p'))
  export LibreEDA_LOGS_PREFIX
fi

# Get overwrite log files
if [[ $@ == *"-overwrite_logs"* ]]; then
  export LibreEDA_OVERWRITE_LOGS=1
fi

# Get no command
if [[ $@ == *"-no_cmd"* ]]; then
  export LibreEDA_NO_CMD=1
fi

# Get no logs
if [[ $@ == *"-no_logs"* ]]; then
  export LibreEDA_NO_LOGS=1
fi

# Determine log file number
if [[ $LibreEDA_OVERWRITE_LOGS -eq 1 ]]; then
  # Get log file with highest number
  LOG_NUM=$(ls -1 ${LibreEDA_LOGS_PREFIX}.log* 2>/dev/null | sed -n 's/.*\.log\([0-9]*\)/\1/p' | sort -n | tail -n 1)

  # Get .cmd file with highest number
  CMD_NUM=$(ls -1 ${LibreEDA_LOGS_PREFIX}.cmd* 2>/dev/null | sed -n 's/.*\.cmd\([0-9]*\)/\1/p' | sort -n | tail -n 1)

  if [[ $LOG_NUM == "" ]]; then
    LOG_NUM=0
  fi
  if [[ $CMD_NUM == "" ]]; then
    CMD_NUM=0
  fi

  # set LibreEDA_LOG_ID as the higher of the two
  if [[ $LOG_NUM -gt $CMD_NUM ]]; then
    export LibreEDA_LOG_ID=$LOG_NUM
  else
    export LibreEDA_LOG_ID=$CMD_NUM
  fi
else
  # find first available number in both .log and .cmd files
  if [[ ! -f ${LibreEDA_LOGS_PREFIX}.log && ! -f ${LibreEDA_LOGS_PREFIX}.cmd ]]; then
    export LibreEDA_LOG_ID=""

  else
    export LibreEDA_LOG_ID=1
    while [[ -f ${LibreEDA_LOGS_PREFIX}.log${LibreEDA_LOG_ID} || -f ${LibreEDA_LOGS_PREFIX}.cmd${LibreEDA_LOG_ID} ]]; do
      export LibreEDA_LOG_ID=$((LibreEDA_LOG_ID+1))
    done

  fi
fi

# set LibreEDA_LOG_ID to "" if it is 0
if [[ $LibreEDA_LOG_ID -eq 0 ]]; then
  export LibreEDA_LOG_ID=""

fi

if [[ $LibreEDA_OVERWRITE_LOGS -eq 1 ]]; then
  rm ${LibreEDA_LOGS_PREFIX}.log${LibreEDA_LOG_ID} ${LibreEDA_LOGS_PREFIX}.cmd${LibreEDA_LOG_ID} 2>/dev/null
fi

export LibreEDA_CMD_FILE=${LibreEDA_LOGS_PREFIX}.cmd${LibreEDA_LOG_ID}

# Run LibreEDA
# Don't create log files if -no_logs is specified
if [[ $LibreEDA_NO_LOGS -eq 1 ]]; then
  $LibreEDA_ROOT_DIR/LibreEDA ${LibreEDA_ARGS}
else
  $LibreEDA_ROOT_DIR/LibreEDA ${LibreEDA_ARGS} | tee -i ${LibreEDA_LOGS_PREFIX}.log${LibreEDA_LOG_ID}
fi

# run stty sane if LibreEDA exits with error
if [[ $? -ne 0 ]]
then
    stty sane
fi
