#!/bin/bash
set -eou pipefail

version=$1
name=$2
cluster_uuid=$3

bootstraps=$(dirname $0)
bash $bootstraps/limits.sh
bash $bootstraps/java8.sh

echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee /etc/apt/sources.list.d/elasticsearch.list
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y elasticsearch=${version}

sudo service elasticsearch stop

heap=$(free -m|head -2|tail -1|awk '{print $2}'|python2.7 -c 'import sys; print int(int(sys.stdin.read()) * .5)')
region=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ 2>/dev/null|sed s:.$::)

bash $bootstraps/set_opt.sh /etc/default/elasticsearch 'ES_HEAP_SIZE=' "${heap}m"
bash $bootstraps/set_opt.sh /etc/default/elasticsearch 'MAX_OPEN_FILES=' '120000'
bash $bootstraps/set_opt.sh /etc/default/elasticsearch 'MAX_LOCKED_MEMORY=' 'unlimited'

bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'cluster.name:' " ${name}"
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'bootstrap.memory_lock:' ' true'
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'network.host:' ' 0.0.0.0'
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'discovery.type:' ' ec2'
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'discovery.ec2.tag.es-cluster:' " ${cluster_uuid}"
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'cloud.aws.region:' " ${region}"
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'cloud.node.auto_attributes:' ' true'

yes | sudo /usr/share/elasticsearch/bin/plugin install cloud-aws
yes | sudo /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head

sudo service elasticsearch start
