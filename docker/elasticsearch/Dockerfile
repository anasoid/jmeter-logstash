ARG LOGSTASH_VERSION=7.17.14
FROM docker.elastic.co/logstash/logstash-oss:${LOGSTASH_VERSION}

ARG ELASTICSEARCH_VERSION=7
ENV ELASTICSEARCH_VERSION ${ELASTICSEARCH_VERSION}

ENV CONF_EXEC_TIMEOUT 86400
ENV CONF_WAIT_FIRST_DATA 60
ENV CONF_WAIT_INACTIVITY 30


RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD config/pipeline/ /usr/share/logstash/pipeline/
ADD config/pipeline-in-csv/ /usr/share/logstash/pipeline-in-csv/
ADD config/settings/ /usr/share/logstash/config/
ADD docker/entrypoint.sh /usr/local/bin/jmeter-logstash-entrypoint.sh


RUN mkdir -p /usr/share/logstash/data/plugins/inputs/file
VOLUME /usr/share/logstash/data/plugins/inputs/file



ENTRYPOINT ["jmeter-logstash-entrypoint.sh"]