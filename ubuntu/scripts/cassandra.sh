#!/bin/bash
set -eu

version=$1
name=$2
seeds=$3

bootstraps=$(dirname $0)
bash $bootstraps/limits.sh
bash $bootstraps/java8.sh

echo "deb http://www.apache.org/dist/cassandra/debian 3$(echo $version|cut -d. -f2)x main" | sudo tee /etc/apt/sources.list.d/cassandra.sources.list
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y cassandra=${version}

sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/*

bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'num_tokens:' ' 256'
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'auto_bootstrap:' ' false'
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'rpc_address:' " 0.0.0.0"

# move to instantiation time
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'cluster_name:' " $name"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml '- seeds:' " $seeds"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'broadcast_rpc_address:' " $(ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1)"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'listen_address:' " $(ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1)"

sudo service cassandra start
