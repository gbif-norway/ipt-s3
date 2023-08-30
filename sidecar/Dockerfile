FROM debian:stable-slim
RUN apt update && \
    apt install -y cron unzip curl screen vim
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o /root/minio-binaries/mc && \
  chmod +x /root/minio-binaries/mc
ENV PATH=$PATH:/root/minio-binaries/
COPY ./sync.sh /root/sync.sh
COPY ./unzip.sh /root/unzip.sh
COPY ./setup.sh /root/setup.sh
CMD  /root/setup.sh && tail -f /dev/null
