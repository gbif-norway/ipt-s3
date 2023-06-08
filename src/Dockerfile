FROM gbif/ipt:2.7.3
RUN apt-get update && apt-get install -y unzip cron s4cmd
COPY run.sh /root/run.sh
COPY sync.sh /root/sync.sh
COPY ojdbc8.jar /root/ojdbc8.jar
COPY unzip.sh /root/unzip.sh
CMD [ "/root/run.sh" ]
