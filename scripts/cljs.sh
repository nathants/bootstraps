#!/bin/bash
set -e

bootstraps=$(dirname $0)
bash ${bootstraps}/lein_java8.sh
bash ${bootstraps}/node6.sh

sudo apt-get update
sudo apt-get -y install python-pip git
sudo pip install edn_format

git clone https://github.com/nathants/cljs
sudo mv cljs/bin/.lein cljs/bin/* /usr/bin

cljs ./cljs/examples/shell.cljs
