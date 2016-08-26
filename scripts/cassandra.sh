#!/bin/bash
set -e

version=$1
name=$2
seeds=$3
ops_addr=$4

bootstraps=$(dirname $0)
bash $bootstraps/limits.sh
bash $bootstraps/java8.sh

echo "deb http://debian.datastax.com/community stable main" | sudo tee /etc/apt/sources.list.d/cassandra.list
echo "deb http://debian.datastax.com/datastax-ddc 3.$(echo $version|cut -d. -f2) main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y datastax-ddc=${version}

sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/*

bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'cluster_name:' " $name"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'num_tokens:' ' 256'
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml '- seeds:' " $seeds"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'auto_bootstrap:' ' false'
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'broadcast_rpc_address:' " localhost"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'listen_address:' " $(ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1)"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'rpc_address:' " 0.0.0.0"

sudo service cassandra start

sudo apt-get install -y datastax-agent
sudo service datastax-agent stop
bash bootstraps/scripts/set_opt.sh /var/lib/datastax-agent/conf/address.yaml stomp_interface: " $ops_addr"
sudo service datastax-agent start

if [ "$ops_addr" = "$(ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1)" ]; then
    sudo apt-get install -y opscenter
    sudo service opscenterd start
    curl -X POST 0.0.0.0:8888/cluster-configs -d '{
        "cassandra": {"seed_hosts": "$seeds"},
        "cassandra_metrics": {},
        "jmx": {"port": "7199"}
    }'
fi
