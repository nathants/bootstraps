#!/bin/bash
set -e

version=$1
name=$2
seeds=$3

bootstraps=$(dirname $0)
bash $bootstraps/limits.sh
bash $bootstraps/java8.sh

echo "deb http://debian.datastax.com/datastax-ddc 3.$(echo $version|cut -d. -f2) main" | sudo tee /etc/apt/sources.list.d/cassandra.sources.list
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y datastax-ddc=${version}

sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/*

bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'cluster_name:' " $name"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'num_tokens:' ' 256'
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml '- seeds:' " $seeds"
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'auto_bootstrap:' ' false'
bash $bootstraps/set_opt.sh /etc/cassandra/cassandra.yaml 'listen_address:' " $(ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1)"

sudo service cassandra start
