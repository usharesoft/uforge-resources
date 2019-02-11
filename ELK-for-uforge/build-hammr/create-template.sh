#!/bin/bash

if [ ! -f "/tmp/elasticsearch-6.4.1-1.noarch.rpm" ]
then
    wget -P /tmp/ -O /tmp/elasticsearch-6.4.1-1.noarch.rpm https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.1.rpm
fi

if [ ! -f "/tmp/kibana-6.4.1-1.x86_64.rpm" ]
then
    wget -P /tmp/ -O /tmp/kibana-6.4.1-1.x86_64.rpm https://artifacts.elastic.co/downloads/kibana/kibana-6.4.1-x86_64.rpm
fi

if [ ! -f "/tmp/logstash-6.4.1-1.noarch.rpm" ]
then
    wget -P /tmp/ -O /tmp/logstash-6.4.1-1.noarch.rpm https://artifacts.elastic.co/downloads/logstash/logstash-6.4.1.rpm
fi

hammr template create --file build-hammr/template-elk-uforge.yml --force
