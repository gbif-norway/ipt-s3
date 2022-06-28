#!/bin/bash
echo $S3_ACCESS_KEY:$S3_SECRET_KEY > /root/passwd-s3fs
chmod 600 /root/passwd-s3fs
echo "[default]" > ~/.s3cfg
echo access_key = $S3_ACCESS_KEY >> ~/.s3cfg
echo secret_key = $S3_SECRET_KEY >> ~/.s3cfg
s4cmd mb s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST
s3fs $S3_BUCKET_NAME /srv/ipt -o passwd_file=/root/passwd-s3fs,use_path_request_style,url=$S3_HOST && \
    catalina.sh run