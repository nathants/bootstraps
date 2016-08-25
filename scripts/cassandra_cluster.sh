#!/bin/bash
# requires https://github.com/nathants/py-aws
# requires https://github.com/nathants/py-util
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

name="cassandra-${cluster_name}"

ids=$(ec2 new $name --type ${ec2_type} ${spot_price} --gigs ${ec2_gigs} --ami trusty --num ${num_instances})
ips=$(ec2 ssh $ids -qyc "ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1")

ops_id=$(echo "$ids"|head -n1)
ops_addr=$(ec2 ssh $ops_id -qyc "ifconfig eth0 |grep 'inet addr'|cut -d: -f2|cut -d' ' -f1")

ec2 tag $ops_id opscenter=true -y

seeds=$(echo "$ips" | head -n3 | tr '\n' ', '| sed 's:.$::')

ec2 ssh $ids -yc "

curl -L https://github.com/nathants/bootstraps/tarball/9b94a3c6dc359ae7039139bb61442e14b276051a | tar zx
mv nathants-bootstraps* bootstraps
bash bootstraps/scripts/cassandra.sh $version $cluster_name $seeds $ops_addr

"
