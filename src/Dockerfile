FROM gbif/ipt:2.7.3
RUN apt-get update && apt-get install -y unzip cron
RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip && \
    cd rclone-*-linux-amd64 && \
    cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    cd ../ && \
    rm -r rclone-*-linux-amd64 && \
    rm rclone-current-linux-amd64.zip
COPY rclone.conf /root/.config/rclone/rclone.conf
COPY run.sh /root/run.sh
COPY sync.sh /root/sync.sh
COPY ojdbc8.jar /root/ojdbc8.jar
# CMD [ "tail", "-f","/dev/null" ]
CMD [ "/root/run.sh" ]
