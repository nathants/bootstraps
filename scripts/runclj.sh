#!/bin/bash
set -eou pipefail

bootstraps=$(dirname $0)
bash ${bootstraps}/lein_java8.sh
bash ${bootstraps}/node6.sh

git clone https://github.com/nathants/runclj
sudo mv runclj/bin/.lein runclj/bin/* /usr/bin

cljs ./runclj/examples/shell.cljs
