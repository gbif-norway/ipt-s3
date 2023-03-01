FROM gbif/ipt:2.6.3

RUN apt-get update &&\
    apt-get install s3fs s4cmd cron rsync -y
COPY run.sh /root/run.sh
COPY sync.sh /root/sync.sh
COPY sync-cron /etc/cron.d/sync-cron
RUN crontab /etc/cron.d/sync-cron
CMD [ "/root/run.sh" ]