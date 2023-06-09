#!/bin/bash
echo "Create the bucket if it doesn't exist"
set +e
s4cmd mb s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST
set -e

# Set environment variables so they are accessible to cron
env >> /etc/environment

echo "Setup cron sync (from local to remote, for backups) every hour"
chmod a+x /root/sync.sh
printf '%s\n\n' '1 * * * * /root/sync.sh 2>&1' > /etc/cron.d/cron-jobs

if [ -z "$S3_ZIP_BUCKET_NAME" ]; then
    echo "$(date): S3_ZIP_BUCKET_NAME is not set, and DWCAs will not be unzipped to this IPT" >> /var/log/unzip.log
else
    echo "Setup cron unzip (from remote, download dwca and unzip to local) every Tuesday at 2pm"
    chmod a+x /root/unzip.sh
    # This '*/5 * * * *' is every 5 minutes, for testing purposes
    printf '%s\n\n' '30 14 * * 2 /root/unzip.sh 2>&1' >> /etc/cron.d/cron-jobs
fi

crontab /etc/cron.d/cron-jobs
cron
