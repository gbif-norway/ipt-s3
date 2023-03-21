FROM gbif/ipt:2.7.3

RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc && \
  chmod +x $HOME/minio-binaries/mc && \
  export PATH=$PATH:$HOME/minio-binaries/
COPY run.sh /root/run.sh
COPY ojdbc8.jar /root/ojdbc8.jar
CMD [ "/root/run.sh" ]
