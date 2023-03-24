#!/bin/bash
set -e
echo "Set up bi-directional mirroring using mc mirror"
mc alias set sigma2 https://storage.gbif-no.sigma2.no $S3_ACCESS_KEY $S3_SECRET_KEY
chmod a+x /root/sync.sh
/root/sync.sh
echo "Starting IPT!"
catalina.sh run &
tomcat_pid=$!
echo "IPT started, copying over ojdbc8 driver"
cp /root/ojdbc8.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc8.jar
# rm /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc-14.jar
echo "Soft restarting tomcat with ojdbc driver in place"
touch /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml
wait $tomcat_pid
