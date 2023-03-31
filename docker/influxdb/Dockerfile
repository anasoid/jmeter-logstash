ARG LOGSTASH_VERSION=7.17.9
FROM docker.elastic.co/logstash/logstash-oss:${LOGSTASH_VERSION}






RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD config/pipeline/ /usr/share/logstash/pipeline/
ADD config/settings/ /usr/share/logstash/config/


RUN mkdir -p /usr/share/logstash/data/plugins/inputs/file
VOLUME /usr/share/logstash/data/plugins/inputs/file

RUN rm -f /usr/share/logstash/pipeline/output-elastic-logstash.conf
ADD docker/influxdb/config/pipeline/ /usr/share/logstash/pipeline/
RUN bin/logstash-plugin install logstash-output-influxdb