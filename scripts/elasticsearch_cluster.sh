#!/bin/bash
# requires https://github.com/nathants/py-aws
# requires an ec2 iam role with ec2 read access named: ec2-read-only
# requires https://stedolan.github.io/jq/
set -e

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

name="elasticsearch-${cluster_name}"

cluster_uuid=$(cat /proc/sys/kernel/random/uuid)

ids=$(ec2 new $name \
          es-cluster=${cluster_uuid} \
          ${spot_price} \
          --type ${ec2_type} \
          --gigs ${ec2_gigs} \
          --num ${num_instances} \
          --ami trusty \
          --role ec2-read-only)

ec2 ssh $ids -yc "
curl -L https://github.com/nathants/bootstraps/tarball/1eeaa3196ecebc3d6a84ea48a9f7a8defe3b4487 | tar zx
mv nathants-bootstraps* bootstraps
bash bootstraps/scripts/elasticsearch.sh $version $cluster_name $cluster_uuid
"

ips=$(ec2 ip $name)
for i in {1..11}; do
    [ $i = 11 ] && echo failed after 10 tries && false
    num_nodes_should_exist=$(for ip in $ips; do echo 3; done)
    num_nodes_exist=$(for ip in $ips; do curl $ip:9200/_cluster/state 2>/dev/null|jq '.nodes|length'; done)
    echo wanted to see: $num_nodes_should_exist
    echo actually saw: $num_nodes_exist
    [ "$num_nodes_should_exist" = "$num_nodes_exist" ] && echo all nodes up && break
    sleep 10
done

min_master=$(($num_instances/2+1))
echo set min master nodes to: $min_master
curl -XPUT localhost:9200/_cluster/settings -d "{\"persistent\" : {\"discovery.zen.minimum_master_nodes\" : $min_master}}\"