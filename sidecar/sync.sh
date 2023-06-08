#!/bin/bash

echo "$(date '+%Y-%m-%d %T') Sync starting" >> /var/log/sync.log
# Sync from local to remote for backups
s4cmd dsync --recursive --sync-check --num-threads=3 /srv/ipt s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST && \
echo "$(date '+%Y-%m-%d %T') Sync completed succesfully" >> /var/log/sync.log
