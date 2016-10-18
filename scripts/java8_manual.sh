#!/bin/bash
set -eou pipefail

big_version=111
small_version=14
link="http://download.oracle.com/otn-pub/java/jdk/8u${big_version}-b${small_version}/jdk-8u${big_version}-linux-x64.tar.gz"
cd $(mktemp -d)
wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=a" $link
tar xf jdk*
rm *.tar.gz
sudo rm -rf /usr/lib/jvm
sudo mkdir -p /usr/lib/jvm
sudo mv jdk* /usr/lib/jvm/jdk1.8.0
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0/bin/javac" 1
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0/bin/javaws" 1
sudo chmod a+x /usr/bin/java
sudo chmod a+x /usr/bin/javac
sudo chmod a+x /usr/bin/javaws
sudo chown -R root:root /usr/lib/jvm/jdk1.8.0
