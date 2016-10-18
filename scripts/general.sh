#!/bin/bash
set -eou pipefail

bootstraps=$(dirname $0)
bash $bootstraps/lein_java8.sh
bash $bootstraps/python34.sh

# TODO
# glances htop curl vim wget jq ag emacs
# ssh port gateway
# limits
# py-aws
