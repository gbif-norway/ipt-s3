#!/bin/bash

echo "$(date -I) Sync starting" >> /var/log/sync.log
# Sync from local to remote for backups
# rclone sync --update --delete-during --verbose --transfers 10 --checkers 10 --contimeout 60s --timeout 300s --retries 3 --low-level-retries 10 --exclude .~tmp~/ $IPT_DATA_DIR sigma2:$S3_BUCKET_NAME && \
s4cmd dsync --recursive --verbose --sync-check --num-threads=5 $IPT_DATA_DIR s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST && \
echo "$(date -I'seconds') Sync complete succesfully" >> /var/log/sync.log
