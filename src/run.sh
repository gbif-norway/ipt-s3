#!/bin/bash
set -e
echo "Starting IPT!"
catalina.sh run & 
echo "IPT started, copying over ojdbc8 driver"
sleep 25
cp /root/ojdbc8.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc8.jar
rm /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc-14.jar
echo "Soft restarting tomcat with ojdbc driver in place"
touch /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml
mc alias set sigma2 https://storage.gbif-no.sigma2.no $S3_ACCESS_KEY $S3_SECRET_KEY
mc mirror --overwrite --watch sigma2/ipt $IPT_DATA_DIR &> /dev/null
mc mirror --overwrite --watch $IPT_DATA_DIR sigma2/ipt &> /dev/null
exec "$@"
