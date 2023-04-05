#!/bin/bash

echo "$(date -I) Sync starting" >> /var/log/sync.log
# Sync from local to remote for backups
rclone sync --update --delete-during --verbose --transfers 10 --checkers 10 --contimeout 60s --timeout 300s --retries 3 --low-level-retries 10 --exclude .~tmp~/ $IPT_DATA_DIR sigma2:$S3_BUCKET_NAME && \
echo "$(date -I) Sync complete succesfully" >> /var/log/sync.log
