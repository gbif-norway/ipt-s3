#!/bin/bash
rsync -avzWS $IPT_DATA_DIR /root/s3data/ --delete-after --no-compress
echo $(date) "Backup complete" >> /var/log/backup.log
echo $(date) "Backup complete"
