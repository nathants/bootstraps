#!/bin/bash
set -eu

cd $(dirname $0)

id=$(ec2 new ena-ami --type r4.large --ami xenial)

ec2 ssh $id -yc ./ena.sh

ec2 stop -y $id --wait

aws ec2 modify-instance-attribute --instance-id $id --ena-support

ec2 ami $id --name ubuntu-xenial-ena

ec2 rm $id -y
