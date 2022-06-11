ARG  LOGSTASH_VERSION=7.17.4
FROM docker.elastic.co/logstash/logstash-oss:${LOGSTASH_VERSION}

RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD config/pipeline/ /usr/share/logstash/pipeline/
ADD config/settings/ /usr/share/logstash/config/

RUN mkdir -p /usr/share/logstash/data/plugins/inputs/file
VOLUME /usr/share/logstash/data/plugins/inputs/file
