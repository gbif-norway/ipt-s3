#!/bin/bash
echo "Starting IPT!"
export JPDA_ADDRESS=*:8000
catalina.sh jpda run &
tomcat_pid=$!
echo "IPT started, copying over ojdbc8 driver"
cp /root/ojdbc8.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ojdbc8.jar
echo "Soft restarting tomcat with ojdbc driver in place"
touch /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml
wait $tomcat_pid
