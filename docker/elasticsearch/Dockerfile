FROM docker.elastic.co/logstash/logstash-oss:7.16.2

RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD config/pipeline/ /usr/share/logstash/pipeline/
ADD config/settings/ /usr/share/logstash/config/

RUN mkdir -p /usr/share/logstash/data/plugins/inputs/file
VOLUME /usr/share/logstash/data/plugins/inputs/file
