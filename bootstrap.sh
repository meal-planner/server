#!/bin/sh

sudo apt-get install curl libc6 libcurl3 zlib1g unzip default-jre -y

ES_VERSION="1.4.2"
curl -L -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ES_VERSION}.zip
unzip elasticsearch-${ES_VERSION}.zip
cd elasticsearch-${ES_VERSION}

sudo ./bin/plugin -i elasticsearch/marvel/latest
echo 'marvel.agent.enabled: false' >> ./config/elasticsearch.yml
./bin/elasticsearch -d
