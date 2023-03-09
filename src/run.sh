#!/bin/bash
set -e
echo $S3_ACCESS_KEY:$S3_SECRET_KEY > /root/passwd-s3fs
chmod 600 /root/passwd-s3fs
echo "[default]" > ~/.s3cfg
echo access_key = $S3_ACCESS_KEY >> ~/.s3cfg
echo secret_key = $S3_SECRET_KEY >> ~/.s3cfg
set +e
s4cmd mb s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST
set -e
mkdir -p /root/s3data/ipt
s3fs $S3_BUCKET_NAME /root/s3data/ipt -o passwd_file=/root/passwd-s3fs,use_path_request_style,url=$S3_HOST
echo "Start copying"
rsync -avzWS /root/s3data/ipt/ $IPT_DATA_DIR
echo "Copying finished"
echo "Start cron"
cron
echo "Starting IPT!"
catalina.sh run & 
echo "IPT started, copying over ojdbc8 driver"
sleep 25
cp /root/ojdbc8.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc8.jar
rm /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc-14.jar
echo "Soft restarting tomcat with ojdbc driver in place"
touch /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml
exec "$@"

