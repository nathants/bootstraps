#!/bin/bash
set -eu

version=$1
cluster_name=$2

bootstraps=$(dirname $0)
bash $bootstraps/limits.sh
bash $bootstraps/java8.sh

echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-5.x.list
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y elasticsearch=$version jq
sudo service elasticsearch stop

echo | sudo tee /etc/default/elasticsearch
bash $bootstraps/set_opt.sh /etc/default/elasticsearch 'MAX_OPEN_FILES=' '120000'
bash $bootstraps/set_opt.sh /etc/default/elasticsearch 'MAX_LOCKED_MEMORY=' 'unlimited'

bash $bootstraps/set_opt.sh /etc/sysctl.conf 'vm.max_map_count=' '262144'

echo | sudo tee /etc/elasticsearch/elasticsearch.yml
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'cluster.name:' " ${cluster_name}"
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'bootstrap.memory_lock:' ' true'
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'network.host:' ' 0.0.0.0'
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'discovery.type:' ' ec2'
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'cloud.node.auto_attributes:' ' true'
bash $bootstraps/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'gateway.recover_after_time:' ' 1m'

yes | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2

# TODO switch to 16.04, all this handled automatically
echo '
description "elasticsearch"
start on (net-device-up IFACE!=lo
          and local-filesystems
          and runlevel [2345])
stop on runlevel [016]
respawn
respawn limit 10 30
limit memlock unlimited unlimited
limit nofile 120000 120000
setuid elasticsearch
setgid elasticsearch
exec /usr/share/elasticsearch/bin/elasticsearch -Edefault.path.home=/usr/share/elasticsearch/ -Edefault.path.data=/var/lib/elasticsearch/ -Edefault.path.conf=/etc/elasticsearch -Edefault.path.logs=/var/log/elasticsearch
' | sudo tee /etc/init/elasticsearch.conf
sudo rm /etc/init.d/elasticsearch
sudo ln -s /lib/init/upstart-job /etc/init.d/elasticsearch
sudo initctl reload-configuration
sudo service elasticsearch stop || true
sudo killall -s 9 -r java || true

sudo service elasticsearch start
