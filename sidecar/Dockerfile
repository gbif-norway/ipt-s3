FROM debian:stable-slim
RUN apt update && \
    apt install -y s4cmd
COPY ./sync.sh /root/sync.sh
COPY ./unzip.sh /root/unzip.sh
CMD ["tail", "-f", "/dev/null"]
