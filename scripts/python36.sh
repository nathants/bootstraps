#!/bin/bash
set -eou pipefail

sudo apt-get update
sudo apt-get install build-essential python-virtualenv
sudo apt-get build-dep -y python3.4
path=/opt/python36
sudo rm -rf ${path}
sudo mkdir -p ${path}
sudo chown $(whoami) ${path}
cd ${path}
wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0a4.tgz
tar xf *
cd *
./configure
make
sudo make install
