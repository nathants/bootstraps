#!/bin/bash
set -eu

ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
ssh-keyscan localhost >> ~/.ssh/known_hosts
