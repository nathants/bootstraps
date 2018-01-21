#!/bin/bash
set -eu

bootstraps=$(dirname $0)
bash $bootstraps/java8.sh
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
sudo mv lein /usr/bin
sudo chmod +x /usr/bin/lein
lein
