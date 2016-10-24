#!/bin/bash
set -eu

sudo apt-get update
sudo apt-get install -y python-software-properties software-properties-common
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
sudo apt-get -y install oracle-java6-installer
