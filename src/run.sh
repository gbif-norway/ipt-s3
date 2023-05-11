#!/bin/bash
# echo "Before startup, sync from remote to local"
# rclone sync --update --verbose --transfers 10 --checkers 10 --contimeout 60s --timeout 300s --retries 3 --low-level-retries 10 --exclude .~tmp~/ sigma2:$S3_BUCKET_NAME $IPT_DATA_DIR
# ✕ Case 1: Bucket does not exist - it breaks!
# ✓ Case 2: Bucket exists but is empty - this should never be the case except the first time an IPT is created, and then I think it will have no effect as tomcat has not yet started and the folders won't have been created in $IPT_DATA_DIR
# ✕ Case 3: Bucket exists but does not contain latest IPT generated publication files - they will get deleted from $IPT_DATA_DIR and it breaks!
# ✓ Case 4: Bucket exists and contains new source files from Corema - the --update flag means these will get overwritten on the local $IPT_DATA_DIR
# ✓ Case 5: Bucket exists and contains old e.g. eml files (because the metadata was updated in the IPT) - the --update flag means the newer eml files in $IPT_DATA_DIR will not get overwritten
echo "Setup cron sync"
chmod a+x /root/sync.sh
printf '%s\n\n' '0 4 * * * /root/sync.sh 2>&1' > /etc/cron.d/sync-cron
crontab /etc/cron.d/sync-cron
cron
echo "Starting IPT!"
catalina.sh run
