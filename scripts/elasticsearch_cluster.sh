#!/bin/bash
# requires https://github.com/nathants/py-aws
# requires an ec2 iam role with ec2 read access named: ec2-read-only
# requires https://stedolan.github.io/jq/
set -eu

# cd to this files parent, so we can access ./files
cd $(dirname $0)
source ./_prompt.sh

version=$1
cluster_name=$2
num_instances=$3
ec2_type=$4
ec2_gigs=$5

if [ -z "$6" ]; then
    spot_price=""
else
    spot_price="--spot $6"
fi

min_master=$(($num_instances/2+1))

prompt version cluster_name num_instances ec2_type ec2_gigs spot_price min_master

name="elasticsearch-${cluster_name}"

ids=$(ec2 new $name \
          cluster-name=${cluster_name} \
          ${spot_price} \
          --type ${ec2_type} \
          --gigs ${ec2_gigs} \
          --num ${num_instances} \
          --ami trusty \
          --role ec2-read-only)

ec2 ssh $ids -yc "
curl -L https://github.com/nathants/bootstraps/tarball/6e982ce9e365298db5df2f504d35f1e7fa1d3f6c | tar zx
mv nathants-bootstraps* bootstraps
bash bootstraps/scripts/elasticsearch.sh $version $cluster_name
"

ec2 ssh $ids -yc "
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'discovery.zen.minimum_master_nodes:' ' ${min_master}'
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'gateway.recover_after_nodes:' ' ${num_instances}'
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'gateway.expected_nodes:' ' ${num_instances}'
sudo service elasticsearch restart
"

ips=$(ec2 ip cluster-name=$cluster_name)
for i in {1..11}; do
    [ $i = 11 ] && echo ERROR all nodes never came up && false
    num_nodes_should_exist=$(for ip in $ips; do echo ${num_instances}; done)
    num_nodes_exist=$(for ip in $ips; do curl $ip:9200/_cluster/state 2>/dev/null|jq '.nodes|length'; done)
    echo wanted to see: $num_nodes_should_exist
    echo actually saw: $num_nodes_exist
    [ "$num_nodes_should_exist" = "$num_nodes_exist" ] && echo all nodes up && break
    sleep 10
done

min_master=$(($num_instances/2+1))
echo set min master nodes to: $min_master
for ip in $ips; do
    curl -XPUT $ip:9200/_cluster/settings -d "{\"persistent\" : {\"discovery.zen.minimum_master_nodes\" : $min_master}}"
done
