#!/bin/bash
echo "Create the bucket if it doesn't exist"
set +e
s4cmd mb s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST
set -e

echo "Setup cron sync (from local to remote, for backups) every hour"
chmod a+x /root/sync.sh
printf '%s\n\n' '1 * * * * S3_BUCKET_NAME=$S3_BUCKET_NAME S3_HOST=$S3_HOST S3_SECRET_KEY=$S3_SECRET_KEY S3_ACCESS_KEY=$S3_ACCESS_KEY /root/sync.sh 2>&1' > /etc/cron.d/cron-jobs

if [ -z "$S3_ZIP_BUCKET_NAME" ]; then
    echo "$(date): S3_ZIP_BUCKET_NAME is not set, and DWCAs will not be unzipped to this IPT" >> /var/log/unzip.log
else
    echo "Setup cron unzip (from remote, download dwca and unzip to local) every Tuesday at 2pm"
    chmod a+x /root/unzip.sh
    printf '%s\n\n' '0 14 * * 2 S3_ZIP_BUCKET_NAME=$S3_ZIP_BUCKET_NAME S3_BUCKET_NAME=$S3_BUCKET_NAME S3_HOST=$S3_HOST S3_SECRET_KEY=$S3_SECRET_KEY S3_ACCESS_KEY=$S3_ACCESS_KEY /root/unzip.sh 2>&1' >> /etc/cron.d/cron-jobs
fi

crontab /etc/cron.d/cron-jobs
cron
