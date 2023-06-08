FROM debian:stable-slim
RUN apt update && \
    apt install -y s4cmd cron
COPY ./sync.sh /root/sync.sh
COPY ./unzip.sh /root/unzip.sh
COPY ./setup.sh /root/setup.sh
CMD  /root/setup.sh && tail -f /dev/null
