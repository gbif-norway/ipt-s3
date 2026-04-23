FROM gbif/ipt:3.3.1
COPY run.sh /usr/local/bin/run-ipt.sh
COPY ojdbc8.jar /usr/local/share/ojdbc8.jar
USER root
RUN chmod 755 /usr/local/bin/run-ipt.sh && chmod 644 /usr/local/share/ojdbc8.jar
CMD [ "/usr/local/bin/run-ipt.sh" ]
