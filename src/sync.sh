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

echo "Initial sync. If a file exists in $IPT_DATA_DIR/.. and it's different on the sigma2/ipt bucket, we overwrite what's on the bucket. This may possibly cause some problems with the corema datasets, where the bucket should take precedence."
mc mirror --overwrite $IPT_DATA_DIR/.. sigma2/ipt

echo "Start continuous bi-directional mirroring"
run_command "mc mirror --overwrite --watch sigma2/ipt $IPT_DATA_DIR/.. &> /dev/null" &
run_command "mc mirror --overwrite --watch --remove $IPT_DATA_DIR/.. sigma2/ipt &> /dev/null" &
