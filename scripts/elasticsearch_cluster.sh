#!/bin/bash
# requires https://github.com/nathants/py-aws
# requires an ec2 iam role with ec2 read access named: ec2-read-only
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
curl -L https://github.com/nathants/bootstraps/tarball/538f1a7beac1edebd052c59dacc9d041c7f9be64 | tar zx
mv nathants-bootstraps* bootstraps
bash bootstraps/scripts/elasticsearch.sh $version $cluster_name $cluster_uuid
"
