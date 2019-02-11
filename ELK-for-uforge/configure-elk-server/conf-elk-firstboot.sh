#!/bin/bash
LOGGER=/var/log/elk/firstboot.log
KIBANA_IMPORT_DASHBOARD_ENDPOINT=http://localhost:5601/api/kibana/dashboards/import
MYSOFTWARE_FOLDER=/uploads/mysoftware/setup-uforge-elk/

function addLogger() {
  echo "INFO " $1 | tee -a $LOGGER
}

function executeUntilExitCodeSuccess() {
  until $1 &> /dev/null
  do
    sleep 5
  done
}

if [ ! -d "/var/log/elk" ]; then
  mkdir /var/log/elk
  touch /var/log/elk/firstboot.log
fi

if [ ! -f "/etc/init.d/elasticsearch" ]; then
  addLogger "Installing Elasticsearch"
  sudo rpm --install "$MYSOFTWARE_FOLDER"elasticsearch-6.4.1-1.noarch.rpm
  systemctl restart elasticsearch
  addLogger "Waiting for Elasticsearch to start"
  executeUntilExitCodeSuccess 'systemctl status elasticsearch'
  addLogger "Elasticsearch is started"
else
  addLogger "Elasticsearch is already installed"
fi

if [ ! -f "/etc/init.d/kibana" ]; then
  addLogger "Installing Kibana"
  sudo rpm --install "$MYSOFTWARE_FOLDER"kibana-6.4.1-1.x86_64.rpm
  systemctl restart kibana
  addLogger "Waiting for Kibana to start"
  executeUntilExitCodeSuccess 'systemctl status kibana'
  addLogger "Kibana is started"
else
  addLogger "Kibana is already installed"
fi

if [ ! -f "/etc/systemd/system/logstash.service" ]; then
  addLogger "Installing Logstash"
  sudo rpm --install "$MYSOFTWARE_FOLDER"logstash-6.4.1-1.noarch.rpm
  systemctl restart logstash
  addLogger "Waiting for Logstash to start"
  executeUntilExitCodeSuccess 'systemctl status logstash'
  addLogger "Logstash is started"
else
  addLogger "Logstash is already installed"
fi

#ELK conf file
addLogger "Starting ELK configuration"
cp "$MYSOFTWARE_FOLDER"elasticsearch.yml /etc/elasticsearch/
cp -r "$MYSOFTWARE_FOLDER"conf.d/ /etc/logstash/
cp "$MYSOFTWARE_FOLDER"kibana.yml /etc/kibana/

#enable services
addLogger "Enabling ELK"
systemctl enable elasticsearch
systemctl enable kibana
systemctl enable logstash

#launch the services
addLogger "Restarting ELK"
systemctl restart elasticsearch
systemctl restart kibana
systemctl restart logstash

addLogger "Waiting for Kibana to be ready"
executeUntilExitCodeSuccess 'curl -f localhost:5601/status'
addLogger "Kibana is ready"

#Adding dashboards
addLogger "Adding dashboards"
curl -X POST $KIBANA_IMPORT_DASHBOARD_ENDPOINT -H 'Content-Type: application/json' -H 'kbn-xsrf: true' -d @"$MYSOFTWARE_FOLDER"dashboards/global-levels.json &> /dev/null
curl -X POST $KIBANA_IMPORT_DASHBOARD_ENDPOINT -H 'Content-Type: application/json' -H 'kbn-xsrf: true' -d @"$MYSOFTWARE_FOLDER"dashboards/appliance-generation.json &> /dev/null
curl -X POST $KIBANA_IMPORT_DASHBOARD_ENDPOINT -H 'Content-Type: application/json' -H 'kbn-xsrf: true' -d @"$MYSOFTWARE_FOLDER"dashboards/web-service.json &> /dev/null

#Add a default index pattern
addLogger 'Setting default index pattern to "*"'
curl -X POST http://localhost:5601/api/kibana/settings/defaultIndex -H 'Content-Type: application/json' -H 'kbn-xsrf: true' -d '{"value":"87f3bcc0-8b37-11e8-83be-afaed4786d8c"}' &> /dev/null
