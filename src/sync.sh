#!/bin/bash
LOG_FILE="/var/log/syncfail.log"

function run_command() {
  local cmd="$1"
  while true; do
    echo "Starting command: $cmd"
    $cmd
    local exit_code=$?
    echo "Command exited with code $exit_code. Restarting in 5 minutes..."
    echo "$(date) - Command \"$cmd\" exited with code $exit_code." >> $LOG_FILE
    sleep 300
  done
}

run_command "mc mirror --overwrite --watch sigma2/ipt $IPT_DATA_DIR &> /dev/null" &
run_command "mc mirror --overwrite --watch $IPT_DATA_DIR sigma2/ipt &> /dev/null" &
