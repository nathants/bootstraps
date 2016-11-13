#!/bin/bash
# requires https://github.com/nathants/py-aws
# requires py-aws ec2 new to have defaults for --key, --vpc, and --sg. ec2 new -h will prompt you on first use, or edit ~/.*.aws.ec2.yaml
#
# usage:
# bash scripts/make_ami.sh elasticsearch '
#   curl -L https://github.com/nathants/bootstraps/tarball/master | tar zx
#   bash nathants-bootstraps*/scripts/elasticsearch.sh 5.0.0 ami-cluster
# '
#
# usage:
# description=foo push_dir=$(pwd) bash scripts/make_ami.sh elasticsearch 'bash bootstraps/scripts/elasticsearch.sh 5.0.0 ami-cluster'
#

set -eu

# cd to this files parent, so we can access ./files
source $(dirname $0)/_prompt.sh

name=$1
remote_cmd=$2

description=${description:-$name}
push_dir=${push_dir:-''}
tag=${tag:-''}

if [ ! -z "$tag" ]; then
    tag="--tag $tag"
fi

prompt name description remote_cmd push_dir tag

id=$(ec2 new make-ami-$name \
         type=new-ami \
         --type m3.medium \
         --gigs 8 \
         --ami trusty)

if [ ! -z "$push_dir" ]; then
    ec2 push $push_dir . $id -y
fi

ec2 ssh $id -yc "$remote_cmd"

ami_id=$(ec2 ami $id --name $name --description $description $tag -y)

ec2 rm $id -y

echo $ami_id
