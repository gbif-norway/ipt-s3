#!/bin/bash

{
    echo "$(date '+%Y-%m-%d - %T') Sync starting"
    /root/minio-binaries/mc mirror --overwrite --remove --preserve /srv/ipt sigma2/$S3_BUCKET_NAME
    echo "$(date '+%Y-%m-%d - %T') Sync complete"
    echo "---------------------"
} >> /var/log/sync.log 2>&1
