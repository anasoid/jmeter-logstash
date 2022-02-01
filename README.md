# jmeter-logstash

Jmeter JTL parsing with Logstash and elasticsearch

# Quick reference

- **Where to get help**:
  - [Issues](https://github.com/anasoid/jmeter-logstash/issues)
  - [Discussions](https://github.com/anasoid/jmeter-logstash/discussions)
  - [Documentation](https://github.com/anasoid/jmeter-logstash)

## Image version

- [`latest`, `7.16`, `7.16.3` ](https://github.com/anasoid/jmeter-logstash/blob/master/docker/elasticsearch/Dockerfile)
- [`influxdb`,`influxdb-7.16`, `influxdb-7.16.3` ](https://github.com/anasoid/jmeter-logstash/blob/master/docker/influxdb/Dockerfile)

## Features

1. Parse Standard JTL (CSV Format).
2. Possibility to filter requests based on regex filter (include and exclude filter) .
3. Flag samplers generated by TransactionController based on regex (by default '_.+_').
4. For TransactionController, calculate number of failing sampler and total.
5. Add relative time to compare different Executions, variable TESTSTART.MS should be logged with property [sample_variables](https://jmeter.apache.org/usermanual/properties_reference.html#results_file_config)
6. Add Project name, test name, environment and executionId to organize results and compare different execution.
7. Split Label name to have multi tags by request (by default split by '/').
8. Flag subresult, when there is a redirection 302,.. Subrequest has a have a suffix like "-xx" when xx is the order number
9. Supporting ElasticSearch , influxDB, and can be adapted for other tools.
10. can also index custom field logged in file with property : [sample_variables](https://jmeter.apache.org/usermanual/properties_reference.html#results_file_config)

## Content

- [jmeter-logstash](#jmeter-logstash)
- [Quick reference](#quick-reference)
  - [Image version](#image-version)
  - [Features](#features)
  - [Content](#content)
  - [Image Variants](#image-variants)
- [Getting Started](#getting-started)
  - [Create ElasticSearch stack (_Only if using ElasticSearch & Kibana_)](#create-elasticsearch-stack-only-if-using-elasticsearch--kibana)
  - [Run Logstash](#run-logstash)
    - [Run Directly for ElasticSearch](#run-directly-for-elasticsearch)
    - [Run With image from docker hub for Elasticsearch](#run-with-image-from-docker-hub-for-elasticsearch)
    - [Run With image from docker hub for InfluxDB](#run-with-image-from-docker-hub-for-influxdb)
  - [Dashboards](#dashboards)
    - [Kibana](#kibana)
  - [HOW-TO](#how-to)
    - [Example](#example)
  - [Parameters](#parameters)
    - [ElasticSearch configuration](#elasticsearch-configuration)
    - [InfluxDB configuration](#influxdb-configuration)
    - [Logstash](#logstash)
  - [Fields](#fields)
- [Troubleshooting & Limitation](#troubleshooting--limitation)

## Image Variants

The `jmeter-logstash` images come in many flavors, each designed for a specific use case.
The images version are based on component used to build image, default use elasticsearch output:

1. **Logstash Version**: 7.16.3 -> default for 7.16.
1. **influxdb** : Pre-configured image with influxdb output.

# Getting Started

## Create ElasticSearch stack (_Only if using ElasticSearch & Kibana_)

1. Create Optional docker network (Called jmeter). If not used remove "--net jmeter " from all following docker command and adapt Elasticsearch url.

```shell
docker network create jmeter
```

2. Start elastic search container , Or use any Elasticsearch instance you have already installed.

```shell
docker run --name jmeter-elastic  --net jmeter \
-p 9200:9200 -p 9300:9300 \
-e "ES_JAVA_OPTS=-Xms1024m -Xmx1024m" \
-e "xpack.security.enabled=false" \
-e "discovery.type=single-node" \
docker.elastic.co/elasticsearch/elasticsearch:7.15.1
```

3. Start Kibana and connect it to elastic search Using environnement variable _ELASTICSEARCH_HOSTS_.

```shell
docker run --name jmeter-kibana  --net jmeter -p 5601:5601 -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" docker.elastic.co/kibana/kibana:7.15.1
```

## Run Logstash

1. Clone this repository or download it.
2. In the project folder create a folder named 'input' or you can use any input folder in your machine.
3. If you choose to use a different input folder, you should change **"${PWD}/input"** on the following command by your input folder.

### Run Directly for ElasticSearch

1. On the project folder execute the following command, (${PWD} it's the current folder). ${PWD} can be replaced by full path to folder.

```shell
docker run --rm -it \
-e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200"  --net jmeter \
-v ${PWD}/input:/input/ \
-v ${PWD}/config/pipeline:/usr/share/logstash/pipeline/ \
-v ${PWD}/config/settings/logstash.yml:/usr/share/logstash/config/logstash.yml \
-v ${PWD}/config/settings/jvm.options:/usr/share/logstash/config/jvm.options \
docker.elastic.co/logstash/logstash:7.15.1

```

### Run With image from docker hub for Elasticsearch

```shell

#Run Image
docker run --rm -it --net jmeter -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" -v ${PWD}/input:/input/ anasoid/jmeter-logstash

```

### Run With image from docker hub for InfluxDB

Adapt parameters for your Influxdb like (INFLUXDB_HOST ..) See [InfluxDB configuration](#influxdb- configuration).

```shell
#Run Image
docker run --rm -it -e "INFLUXDB_HOST=localhost" -v ${PWD}/input:/input/ anasoid/jmeter-logstash:influxdb

```

## Dashboards

### Kibana

Download Dashboards from [Kibana Dashboards](/docs/kibana/jmeter-jtl-kibana.ndjson) and go to Stack management kibana -> saved object for import.

| Main Dashboard                                                | Compare Dashboard                                                     |
| ------------------------------------------------------------- | --------------------------------------------------------------------- |
| <img src="/docs/kibana/images/report-jtl.jpg"  width="400" /> | <img src="/docs/kibana/images/report-jtl-compare.jpg"  width="400" /> |

## HOW-TO

1. To read files from the beginning use the folowing arguments (**-e "FILE_READ_MODE=read" -e "FILE_START_POSITION=beginning"** ) with logstash .
2. To exit after all files parsed use (** -e "FILE_EXIT_AFTER_READ=true" **), should be used with (**-e "FILE_READ_MODE=read" -e "FILE_START_POSITION=beginning" **) .
3. To not remove container logstash after execution not use --rm from arguments.
4. To not remove input File after after indexation use (**-e "FILE_COMPLETED_ACTION=log"**) , removing input file is the default behavior if (**-e "FILE_READ_MODE=read"**).
5. Logstash keep information on position f last line parsed in a file sincedb, this file by default is on the path _/usr/share/logstash/data/plugins/inputs/file_, if you use the same container this file will be persisted even you restart logstash cotainer, and if you need to maintain this file even you remove container you can mount volume folder in the path (_/usr/share/logstash/data/plugins/inputs/file_)
6. To have relative time for comparison test start time should be logged :
   in user.properties file (sample_variables=TESTSTART.MS,...) or add properties with file using -q argument or directly in command line with (-Jsample_variables=TESTSTART.MS,..) see [Full list of command-line options](https://jmeter.apache.org/usermanual/get-started.html#options)

### Example

Run Logstash without remove container after stop.

```shell
docker run   -it --net jmeter -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" \
-v ${PWD}/input:/input/ \
anasoid/jmeter-logstash

```

Run Logstash and start file fom beginning (this will remove file after the end of reading).

```shell
docker run --rm -it --net jmeter -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" \
-v ${PWD}/input:/input/ \
-e "FILE_READ_MODE=read" \
-e "FILE_START_POSITION=beginning" \
anasoid/jmeter-logstash

```

Run Logstash and start file fom beginning (without removing file).

```shell
docker run --rm -it --net jmeter -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" \
-v ${PWD}/input:/input/ \
-e "FILE_READ_MODE=read" \
-e "FILE_START_POSITION=beginning" \
-e "FILE_COMPLETED_ACTION=log" \
anasoid/jmeter-logstash

```

Run Logstash without with external sincedb folder.

```shell
docker run --rm -it --net jmeter -e "ELASTICSEARCH_HOSTS=http://jmeter-elastic:9200" \
-v ${PWD}/input:/input/ \
-v ${PWD}/.sincedb:/usr/share/logstash/data/plugins/inputs/file \
anasoid/jmeter-logstash

```

Run Logstash with influxDB custom port.

```shell
#Run Image
docker run --rm -it -e "INFLUXDB_PORT=9090" -e "INFLUXDB_HOST=localhost" -v ${PWD}/input:/input/ anasoid/jmeter-logstash:influxdb


```

## Parameters

### ElasticSearch configuration

| Environment variables            | Description                                                                                                                                                                               | Default                   |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `ELASTICSEARCH_HOSTS`            | Elasticsearch output configuration [hosts](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html#plugins-outputs-elasticsearch-hosts)                       | http://elasticsearch:9200 |
| `ELASTICSEARCH_INDEX`            | Elasticsearch output configuration [index](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html#plugins-outputs-elasticsearch-index)                       | jmeter-jtl-%{+YYYY.MM.dd} |
| `ELASTICSEARCH_USER`             | Elasticsearch output configuration [user](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html#plugins-outputs-elasticsearch-user)                         |                           |
| `ELASTICSEARCH_PASSWORD`         | Elasticsearch output configuration [password](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html#plugins-outputs-elasticsearch-password)                 |                           |
| `ELASTICSEARCH_HTTP_COMPRESSION` | Elasticsearch output configuration [http_compression](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html#plugins-outputs-elasticsearch-http_compression) | false                     |

### InfluxDB configuration

| Environment variables  | Description                                                                                                                                                      | Default   |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `INFLUXDB_HOST`        | InfluxDB output configuration [host](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-influxdb.html#plugins-outputs-influxdb-host)               | localhost |
| `INFLUXDB_PORT`        | InfluxDB output configuration [port](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-influxdb.html#plugins-outputs-influxdb-port)               | 8086      |
| `INFLUXDB_USER`        | InfluxDB output configuration [user](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-influxdb.html#plugins-outputs-influxdb-user)               |           |
| `INFLUXDB_PASSWORD`    | InfluxDB output configuration [password](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-influxdb.html#plugins-outputs-influxdb-password)       |           |
| `INFLUXDB_DB`          | InfluxDB output configuration [DB](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-influxdb.html#plugins-outputs-influxdb-db)                   | false     |
| `INFLUXDB_MEASUREMENT` | InfluxDB output configuration [measurement](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-influxdb.html#plugins-outputs-influxdb-measurement) | false     |

### Logstash

| Environment variables                | Description                                                                                                                                                           | Default   |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `INPUT_PATH`                         | Default folder input used , pattern : (`["${INPUT_PATH:/input}/**.jtl","${INPUT_PATH:/input}/**.csv"]`)                                                               | /input    |
| `PROJECT_NAME`                       | Project name                                                                                                                                                          | undefined |
| `ENVIRONMENT_NAME`                   | Environment name, if not provided will try to extract value from file name ( {test_name}-{environment-name}-{execution_id} )                                          | undefined |
| `TEST_NAME`                          | Test name, if not provided will try to extract value from file name ( {test_name}-{environment-name}-{execution_id} or {test_name}-{execution_id} or {test_name})     | undefined |
| `EXECUTION_ID`                       | Execution Id, if not provided will try to extract value from file name ( {test_name}-{environment-name}-{execution_id} or {test_name}-{execution_id} )                | undefined |
| `FILE_READ_MODE`                     | File input configuration [mode](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html#plugins-inputs-file-mode)                                   | tail      |
| `FILE_START_POSITION`                | File input configuration [start_position](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html#plugins-inputs-file-start_position)               | end       |
| `FILE_EXIT_AFTER_READ`               | File input configuration [exit_after_read](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html#plugins-inputs-file-exit_after_read)             | false     |
| `FILE_COMPLETED_ACTION`              | File input configuration [file_completed_action](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html#plugins-inputs-file-file_completed_action) | delete    |
| `MISSED_RESPONSE_CODE`               | Default response code when not present in response like on timeout case                                                                                               | 510       |
| `PARSE_LABELS_SPLIT_CHAR`            | Char to split label into labels                                                                                                                                       | /         |
| `PARSE_TRANSACTION_REGEX`            | Regex to identify transaction Label                                                                                                                                   | \_.+\_    |
| `PARSE_TRANSACTION_AUTO`             | Detect transaction controller based on URL null, and message format.                                                                                                  | true      |
| `PARSE_FILTER_INCLUDE_SAMPLER_REGEX` | Regex used to include samplers and transactions.                                                                                                                      |           |
| `PARSE_FILTER_EXCLUDE_SAMPLER_REGEX` | Regex used to exclude samplers and transactions.                                                                                                                      |           |
| `PARSE_REMOVE_TRANSACTION`           | Remove transaction.                                                                                                                                                   | false     |
| `PARSE_REMOVE_SAMPLER`               | Remove sampler, not transaction.                                                                                                                                      | false     |
| `PARSE_REMOVE_MESSAGE_FIELD`         | Remove field message.                                                                                                                                                 | true      |
| `PARSE_CLEANUP_FIELDS`               | Remove fields : host, path.                                                                                                                                           | true      |
| `PARSE_WITH_FLAG_SUBRESULT`          | Flag result with prefix like have a suffix like "-xx" when xx is the order number                                                                                     | true      |

## Fields

For csv field see documentation on [CSV Log format](https://jmeter.apache.org/usermanual/listeners.html#csvlogformat).

For additional fields see documentation on [Results file configuration](https://jmeter.apache.org/usermanual/properties_reference.html#results_file_config).

| Environnement variable      | Type InfluxDB | Type ELK | source        | Description                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| --------------------------- | ------------- | -------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `@timestamp`                | -             | date     | elk           | Insertion time in Elastic search                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `Connect`                   | long          | long     | csv           | time to establish connection                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `IdleTime`                  | long          | long     | csv           | number of milliseconds of 'Idle' time (normally 0)                                                                                                                                                                                                                                                                                                                                                                                               |
| `Latency`                   | long          | long     | csv           | time to first response                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `URL`                       | string (tag)  | string   | csv           |                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `allThreads`                | long          | long     | csv           | total number of active threads in all groups                                                                                                                                                                                                                                                                                                                                                                                                     |
| `bytes`                     | long          | long     | csv           | number of bytes in the sample                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `dataType`                  | string        | string   | csv           | e.g. text                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `domain`                    | string (tag)  | string   | parsing       | domain name or ip which is extracted from url.                                                                                                                                                                                                                                                                                                                                                                                                   |
| `elapsed`                   | long          | long     | csv           | elapsed - in milliseconds                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `environment`               | string (tag)  | string   | input/parsing | Target environment (Ex: dev, stage ..), as input using environment variable or extracted from filename.                                                                                                                                                                                                                                                                                                                                          |
| `executionid`               | string (tag)  | string   | input/parsing | Unique id to identify data for a test, as input using environment variable or extracted from filename.                                                                                                                                                                                                                                                                                                                                           |
| `failureMessage`            | string        | string   | csv           |                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `filename`                  | string (tag)  | string   | parsing       | csv file name without extension.                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `globalLabel`               | string (tag)  | string   | parsing       | Normalized label for subresults, when there redirection (ex 302) jmeter log all redirects requests and the parent one by default (_jmeter.save.saveservice.subresults=false_ to disable), the parent will have the normal label and other subresut will have a suffix like "-xx" when xx is the order number, in this field you will find the original label for all subresult without the number suffix (see field : subresult, redirectLevel ) |
| `grpThreads`                | long          | long     | csv           | number of active threads in this thread group                                                                                                                                                                                                                                                                                                                                                                                                    |
| `host`                      | -             | string   | elk           | hostname of logstash node.                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `label`                     | string (tag)  | string   | csv           | sampler label                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `labels`                    | -             | string   | parsing       | List of keywords extracted by splitting label using the char "PARSE_LABELS_SPLIT_CHAR" from environment variable , default to "/"                                                                                                                                                                                                                                                                                                                |
| `path`                      | -             | string   | logstash      | Path of csv file.                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `project`                   | string (tag)  | string   | input         | Project name.                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `redirectLevel`             | long (tag)    | long     | parsing       | redirect number (see field: _globalLabel_)                                                                                                                                                                                                                                                                                                                                                                                                       |
| `relativetime`              | float         | float    | parsing       | Number of milliseconds from test started. Useful to compare test. this field need to have started test time logged to csv (add this variable name _TESTSTART.MS_ to property _sample_variables_)                                                                                                                                                                                                                                                 |
| `request`                   | string (tag)  | string   | parsing       | Request path if Http/s request.                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `responseCode`              | string (tag)  | string   | csv           |                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `responseMessage`           | string (tag)  | string   | csv           |                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `responseStatus`            | long (tag)    | long     | parsing       | Numeric responseCode , if responseCode is not numeric (case on timeout) using value "MISSED_RESPONSE_CODE" from environment variable , default to 510.                                                                                                                                                                                                                                                                                           |
| `sentBytes`                 | long          | long     | csv           | number of bytes sent for the sample.                                                                                                                                                                                                                                                                                                                                                                                                             |
| `subresult`                 | boolean (tag) | boolean  | parsing       | true if sample is a sub result (see field: _globalLabel_)                                                                                                                                                                                                                                                                                                                                                                                        |
| `success`                   | boolean (tag) | boolean  | csv           | true or false.                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `testname`                  | string (tag)  | string   | parsing       | Test name, as input using environment variable or extracted from filename.                                                                                                                                                                                                                                                                                                                                                                       |
| `teststart`                 | -             | date     | csv           | Test start time. This field need to have started test time logged to csv (add this variable name _TESTSTART.MS_ to property _sample_variables_)                                                                                                                                                                                                                                                                                                  |
| `threadGrpId`               | long          | long     | parsing       | The number of thread group. (Extract from threadName) .                                                                                                                                                                                                                                                                                                                                                                                          |
| `threadGrpName`             | string (tag)  | string   | parsing       | The name of thread group.(Extract from threadName) .                                                                                                                                                                                                                                                                                                                                                                                             |
| `workerNode`                | string (tag)  | string   | parsing       | host port of worker node. (Extract from threadName) .                                                                                                                                                                                                                                                                                                                                                                                            |
| `threadNumber`              | long          | long     | parsing       | The number of thread (unique in thread group). (Extract from threadName) .                                                                                                                                                                                                                                                                                                                                                                       |
| `threadName`                | string (tag)  | string   | csv           | Thread name, unique on test.                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `timestamp`                 | -             | date     | csv           | Request time. Accept timestamp format in ms or "yyyy/MM/dd HH:mm:ss.SSS" .                                                                                                                                                                                                                                                                                                                                                                       |
| `transaction`               | boolean (tag) | boolean  | parsing       | IS Sampler transaction , generated by transaction controller, to identify transaction label should start and and with "\_", the regex used to this is "\_.+\_"                                                                                                                                                                                                                                                                                   |
| `transactionFailingSampler` | long          | long     | parsing       | If sample is transaction, this value represent number of failing sampler.                                                                                                                                                                                                                                                                                                                                                                        |
| `transactionTotalSampler`   | long          | long     | parsing       | If sample is transaction, this value represent count of total sampler.                                                                                                                                                                                                                                                                                                                                                                           |

# Troubleshooting & Limitation

1. Logstash instance can't parse CSV file with different header Format, as first header will be used for all file, if you have files with different format you should use each time a new instance or restart the instance.
1. Change sincedb file can't done on logstash with Elasticsearch without building image.
1. Label with suffix '-{number}' will be considered as subresult, so don't prefix label with '-{number}' or disable subresult flag with PARSE_WITH_FLAG_SUBRESULT.
