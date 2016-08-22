#!/bin/bash
set -e

bootstraps=$(dirname $0)
bash ${bootstraps}/lein_java8.sh
bash ${bootstraps}/node6.sh

sudo apt-get update
sudo apt-get -y install python-pip git
sudo pip install edn_format

git clone https://github.com/nathants/runclj
sudo mv runclj/bin/.lein runclj/bin/* /usr/bin

cljs ./runclj/examples/shell.cljs
