#!/bin/bash
/root/minio-binaries/mc alias set sigma2 $S3_HOST $S3_ACCESS_KEY $S3_SECRET_KEY

echo "Create the bucket if it doesn't exist"
set +e
/root/minio-binaries/mc mb "sigma2/$S3_BUCKET_NAME"
set -e

# Set environment variables so they are accessible to cron
env >> /etc/environment

echo "Setup cron sync (from local to remote, for backups) every 3 hours (larger IPT backups can take a long time)"
chmod a+x /root/sync.sh
printf '%s\n\n' '0 */3 * * * /root/sync.sh 2>&1' > /etc/cron.d/cron-jobs

crontab /etc/cron.d/cron-jobs
cron
