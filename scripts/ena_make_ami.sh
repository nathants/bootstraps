#!/bin/bash
set -eu

cd $(dirname $0)

id=$(ec2 new ena-ami --type i3.large --ami $(ec2 amis-ubuntu --ena|grep xenial|grep hvm-ssd|awk '{print $1}'))
ec2 ssh $id -yc ./ena.sh

ec2 stop -y $id --wait

aws ec2 modify-instance-attribute --instance-id $id --ena-support

ec2 ami $id --name ubuntu-xenial-ena

ec2 rm $id -y
