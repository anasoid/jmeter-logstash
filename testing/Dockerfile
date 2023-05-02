ARG LOGSTASH_VERSION=7.17.10
FROM docker.elastic.co/logstash/logstash-oss:${LOGSTASH_VERSION}

ARG ELASTICSEARCH_VERSION=7
ENV ELASTICSEARCH_VERSION ${ELASTICSEARCH_VERSION}

RUN bin/logstash-plugin install logstash-codec-csv

RUN mkdir -p /usr/share/logstash/data/plugins/inputs/file
VOLUME /usr/share/logstash/data/plugins/inputs/file
