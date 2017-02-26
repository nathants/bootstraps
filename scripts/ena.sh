#!/bin/bash
set -eu

# setup ena support ec2 instances on ubuntu xenial

ethtool -i ens3|grep ena # assert that ena is available
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential dkms git
git clone https://github.com/amzn/amzn-drivers
sudo mv amzn-drivers /usr/src/amzn-drivers-1.0.0
sudo touch /usr/src/amzn-drivers-1.0.0/dkms.conf

echo 'PACKAGE_NAME="ena"
PACKAGE_VERSION="1.0.0"
CLEAN="make -C kernel/linux/ena clean"
MAKE="make -C kernel/linux/ena/ BUILD_KERNEL=${kernelver}"
BUILT_MODULE_NAME[0]="ena"
BUILT_MODULE_LOCATION="kernel/linux/ena"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="ena"
AUTOINSTALL="yes"' | sudo tee /usr/src/amzn-drivers-1.0.0/dkms.conf

sudo dkms add -m amzn-drivers -v 1.0.0
sudo dkms build -m amzn-drivers -v 1.0.0
sudo dkms install -m amzn-drivers -v 1.0.0
sudo update-initramfs -c -k all
modinfo ena|grep version # assert ena is available
