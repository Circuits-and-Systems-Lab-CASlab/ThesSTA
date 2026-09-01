#!/usr/bin/bash
# Strips ANSI codes, version banner, prompt prefix, and CPU-time lines from
# a raw log, and rewrites the absolute testcase-data path to a placeholder,
# so golden files diff cleanly across machines. Banner/prompt patterns don't
# hardcode a tool name, so they keep working across renames (LibreEDA/
# ThesSTA/pathviz).
#
# Usage: normalize_log.sh <raw_log_file> <testcase_data_dir>

set -euo pipefail

RAW_LOG=$1
DATA_DIR=$2

sed -E "s/\x1b\[[0-9;]*m//g; /^[^ ]+ .*Version:.*Compiled on/d; s/^\[[^]]+\]%> //; /^REPORT: CPU Time/d" "$RAW_LOG" \
  | sed "s#${DATA_DIR}#<TESTCASE_DATA>#g"
