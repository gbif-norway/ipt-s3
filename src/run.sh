#!/bin/bash
echo "Create the bucket if it doesn't exist"
set +e
s4cmd mb s3://$S3_BUCKET_NAME --endpoint-url $S3_HOST
set -e

echo "Setup cron sync (from local to remote, for backups), to run every hour"
chmod a+x /root/sync.sh
printf '%s\n\n' '1 * * * * /root/sync.sh 2>&1' > /etc/cron.d/sync-cron
crontab /etc/cron.d/sync-cron
cron

echo "Starting IPT!"
catalina.sh run &
tomcat_pid=$!
echo "IPT started, copying over ojdbc8 driver"
cp /root/ojdbc8.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc8.jar
# rm /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc-14.jar
echo "Soft restarting tomcat with ojdbc driver in place"
touch /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml
wait $tomcat_pid
