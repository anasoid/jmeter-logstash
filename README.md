# jmeter-logstash

Jmeter JTL parsing with Logstash and elasticsearch

## Features

1. TODO

## Getting Started

This config is tested with ELK version **7.15.1**, but it is not directly dependent by this version it should work with other version 7.xxx (maybe _8.xx_ ).

### Create ElasticSearch stack

1. Create Optional docker network (Called jmeter). If not used remove "--net jmeter " from all following docker command.

```
docker network create jmeter
```

1. Start elastic search container , Or use any Elasticsearch instance you have already installed.

```
docker run --name jmeter-elastic --net jmeter -p 9200:9200 -p 9300:9300 -e "xpack.security.enabled=false" -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.15.1
```

1. Start Kibana and connect it to elastic search Using environnement variable _ELASTICSEARCH_HOSTS_.

```
docker run --name jmeter-kibana --net jmeter -p 5601:5601 -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" docker.elastic.co/kibana/kibana:7.15.1
```

## Run Logstash

1. Clone this repository or download it.
2. In the project folder create a folder named 'input' or you can use any input folder in your machine.
3. If you choose to use a different input folder, you should change **"${PWD}/input"** on the following command by your input folder.
4. On the project folder execute the following command, (${PWD} it's the current folder). ${PWD} can be replaced by full path to folder.

```
docker run --rm -it --net jmeter \
-e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" \
-v ${PWD}/input:/input/ \
-v ${PWD}/config/pipeline:/usr/share/logstash/pipeline/ \
-v ${PWD}/config/settings/logstash.yml:/usr/share/logstash/config/logstash.yml \
docker.elastic.co/logstash/logstash:7.15.1

```

### Parameters

| Environement variable   | Description       | Default               |
| ----------------------- | ----------------- | --------------------- |
| **ELASTICSEARCH_HOSTS** | Elasticsearch url | http://localhost:9200 |
