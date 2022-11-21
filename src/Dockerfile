FROM gbif/ipt:2.6.3
COPY run.sh /root/run.sh
COPY sync.sh /root/sync.sh
RUN apt-get update &&\
    apt-get install s3fs s4cmd inotify-tools rsync -y &&\
    chmod a+x /root/run.sh 
CMD [ "/root/run.sh" ]