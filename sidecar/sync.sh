#!/bin/bash

{
    echo "bucket_name: $S3_BUCKET_NAME, S3_HOST: $S3_HOST, S3_SECRET_KEY: $S3_SECRET_KEY, S3_ACCESS_KEY: $S3_ACCESS_KEY."
    echo "$(date '+%Y-%m-%d %T') Sync starting" >> /var/log/sync.log
    # Sync from local to remote for backups
    s4cmd dsync --recursive --sync-check --num-threads=3 /srv/ipt s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST && \
    echo "$(date '+%Y-%m-%d %T') Sync completed succesfully" >> /var/log/sync.log
} >> /var/log/syncdebug.log 2>&1
