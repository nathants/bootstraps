#!/bin/bash
set -eu

cd $(dirname $0)

id=$(ec2 new ena-ami --type i3.large --ami ami-f9d25199)
ec2 ssh $id -yc ./ena.sh

aws ec2 stop-instances --instance-ids $id

aws ec2 modify-instance-attribute --instance-id $id --ena-support

ec2 ami $id --name ubuntu-xenial-ena
