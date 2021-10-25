# jmeter-logstash
Jmeter JTL parsing with Logstash and elasticsearch


## Create ElasticSearch stack

```

docker pull docker.elastic.co/kibana/kibana:7.15.1
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.15.1

docker network create jmeter

docker run --name jmeter-elastic --net jmeter -p 9200:9200 -p 9300:9300 -e "xpack.security.enabled=false" -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.15.1
docker run --name jmeter-kibana --net jmeter -p 5601:5601 -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" docker.elastic.co/kibana/kibana:7.15.1


```

## Run Logstash

```
docker run --rm -it --net jmeter \
-e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" \
-v ${PWD}/test:/input/ \
-v ${PWD}/config/pipeline:/usr/share/logstash/pipeline/ \
-v ${PWD}/config/settings/logstash.yml:/usr/share/logstash/config/logstash.yml \
docker.elastic.co/logstash/logstash:7.15.1

```