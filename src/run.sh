#!/bin/bash
# The rclone sync below syncs from remote to local
# Run this manually in the container only once if the container is started up with an empty pvc
# Otherwise, remote should only be used to back up
# rclone sync --update --verbose --transfers 10 --checkers 10 --contimeout 60s --timeout 300s --retries 3 --low-level-retries 10 --exclude .~tmp~/ sigma2:$S3_BUCKET_NAME $IPT_DATA_DIR
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
