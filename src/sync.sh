#!/bin/bash
BUCKET="sigma2/ipt"
LOG_FILE="/var/log/syncfail.log"

function check_and_copy_bucket() {
  if [ ! -d "$IPT_DATA_DIR" ]; then
    echo "Directory $IPT_DATA_DIR does not exist, checking if the bucket is not empty."
    bucket_size=$(mc ls "$BUCKET" | wc -l)
    if [ "$bucket_size" -gt 0 ]; then
      echo "Bucket is not empty, copying contents to $IPT_DATA_DIR."
      mkdir -p "$IPT_DATA_DIR"
      mc cp --recursive "$BUCKET" "$IPT_DATA_DIR"
    fi
  else
    dir_size=$(find "$IPT_DATA_DIR" -mindepth 1 -not -name "lost+found" | wc -l)
    if [ "$dir_size" -eq 0 ]; then
      echo "Directory $IPT_DATA_DIR is empty, copying contents from the bucket."
      mc cp --recursive "$BUCKET" "$IPT_DATA_DIR/.."
    fi
  fi
}

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

check_and_copy_bucket

run_command "mc mirror --overwrite --watch sigma2/ipt $IPT_DATA_DIR/.. &> /dev/null" &
run_command "mc mirror --overwrite --watch --remove $IPT_DATA_DIR/.. sigma2/ipt &> /dev/null" &
