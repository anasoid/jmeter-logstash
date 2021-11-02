FROM docker.elastic.co/logstash/logstash:7.15.1

RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD config/pipeline/ /usr/share/logstash/pipeline/
ADD config/settings/ /usr/share/logstash/config/


RUN rm -f /usr/share/logstash/pipeline/output-elastic-logstash.conf
ADD docker/influxdb/config/pipeline/ /usr/share/logstash/pipeline/
RUN bin/logstash-plugin install logstash-output-influxdb