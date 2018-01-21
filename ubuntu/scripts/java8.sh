#!/bin/bash
set -eu

sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

mv ~/.bashrc ~/.bashrc.bak
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' > ~/.bashrc
cat ~/.bashrc.bak >> ~/.bashrc
rm ~/.bashrc.bak
