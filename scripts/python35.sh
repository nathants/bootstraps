#!/bin/bash
set -eou pipefail

sudo apt-get update
sudo apt-get install build-essential python-virtualenv
sudo apt-get build-dep -y python3.4
path=/opt/python35
sudo rm -rf ${path}
sudo mkdir -p ${path}
sudo chown $(whoami) ${path}
cd ${path}
wget https://www.python.org/ftp/python/3.5.0/Python-3.5.0.tgz
tar xf *
cd *
./configure
make
sudo make install
