FROM gbif/ipt:2.7.3

RUN apt-get update &&\
    apt-get install s3fs s4cmd cron rsync -y
COPY run.sh /root/run.sh
COPY sync.sh /root/sync.sh
COPY ojdbc8.jar /root/ojdbc8.jar
RUN printf '%s\n\n' '1 * * * * /root/sync.sh 2>&1' > /etc/cron.d/sync-cron
RUN crontab /etc/cron.d/sync-cron
CMD [ "/root/run.sh" ]
