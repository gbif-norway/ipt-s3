FROM gbif/ipt:2.5.8
COPY run.sh /root/run.sh
RUN apt-get update &&\
    apt-get install s3fs s4cmd -y &&\
    chmod a+x /root/run.sh 
CMD [ "/root/run.sh" ]