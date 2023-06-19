#!/bin/bash

s4cmd dsync --recursive --sync-check --num-threads=3 /srv/ipt/config s3://$S3_BUCKET_NAME/config --endpoint-url $S3_HOST && \
echo "$(date '+%Y-%m-%d %T') CONFIG Sync completed succesfully" >> /var/log/sync.log

s4cmd dsync --recursive --sync-check --num-threads=3 /srv/ipt/logs s3://$S3_BUCKET_NAME/logs --endpoint-url $S3_HOST && \
echo "$(date '+%Y-%m-%d %T') LOGS Sync completed succesfully" >> /var/log/sync.log

echo "----- NEW RESOURCES SYNC STARTING - $(date '+%Y-%m-%d - %T') -----" >> /var/log/sync.log
{
	base_dir="/srv/ipt/resources"
	for subdir in "${base_dir}"/*; do
	    if [ -d "$subdir" ]; then
		suffix="${subdir#$base_dir}"
		/usr/bin/s4cmd dsync --sync-check "${subdir}" --recursive --num-threads=1 --verbose "s3://$S3_BUCKET_NAME/resources${suffix}" --endpoint-url $S3_HOST
		exit_status=$?
		if [ $exit_status -ne 0 ]; then
		    echo "s4cmd dsync failed for ${subdir} with exit status ${exit_status}" >> /var/log/sync.log 
		fi
		sleep 0.1
	    fi
	done
} >> /var/log/syncdebug.log 2>&1
