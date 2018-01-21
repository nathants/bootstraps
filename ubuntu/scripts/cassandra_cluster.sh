#!/bin/bash
# requires https://github.com/nathants/py-aws
set -eu

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

name="cassandra-${cluster_name}"

ids=$(ec2 new $name \
          ${spot_price} \
          --type ${ec2_type} \
          --gigs ${ec2_gigs} \
          --ami trusty \
          --num ${num_instances})
ips=$(ec2 ssh $ids -qyc "ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1")

seeds=$(echo "$ips" | head -n3 | tr '\n' ', '| sed 's:.$::')

ec2 ssh $ids -yc "
curl -L https://github.com/nathants/bootstraps/tarball/85bfc979230271bc18d178c9ca3a21817b1dfa45 | tar zx
mv nathants-bootstraps* bootstraps
bash bootstraps/scripts/cassandra.sh $version $cluster_name $seeds
"

# TODO add something like in elasticsearch_cluster.sh, that checks
# that the correct number of nodes came up, and that they all can see
# each other
