#!/bin/bash
echo $S3_ACCESS_KEY:$S3_SECRET_KEY > /root/passwd-s3fs
chmod 600 /root/passwd-s3fs
echo "[default]" > ~/.s3cfg
echo access_key = $S3_ACCESS_KEY >> ~/.s3cfg
echo secret_key = $S3_SECRET_KEY >> ~/.s3cfg
s4cmd mb s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST
s3fs $S3_BUCKET_NAME $IPT_DATA_DIR -o passwd_file=/root/passwd-s3fs,use_path_request_style,url=$S3_HOST && \
    touch ${IPT_DATA_DIR}/config/custom.css && \
    cp ${IPT_DATA_DIR}/config/custom.css /usr/local/tomcat/webapps/ROOT/styles/custom.css && \
    catalina.sh run
