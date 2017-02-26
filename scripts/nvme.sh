#!/bin/bash
set -eu

# TODO seems unusable. with a 16GB file of word,word,word\n, trying to wc -l gets IO errors. 16.04, kernel 4.4, 4.8, 4.10.1

# setup nvme on an aws i3 instance

(
 echo g # Create a new empty GPT partition table
 echo n # Add a new partition
 echo 1 # Partition number
 echo   # First sector (Accept default: 1)
 echo   # Last sector (Accept default: varies)
 echo w # Write changes
) | sudo fdisk /dev/nvme0n1
sleep 2
sudo mkfs -t ext4 /dev/nvme0n1p1
sudo mkdir /media/nvme
sudo mount -o discard /dev/nvme0n1p1 /media/nvme
sudo chown -R ubuntu:ubuntu /media/nvme

uuid=$(sudo blkid|grep nvme0n1p1|sed -r 's/.* UUID="([^"]+)".*/\1/')
echo "UUID=$uuid /media/nvme ext4 defaults,discard 0 0" | sudo tee -a /etc/fstab

sudo mount -a # verify no errors in fstab
