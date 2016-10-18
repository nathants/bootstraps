#!/bin/bash
set -eou pipefail
mkdir -p ~/opt
cd ~/opt
sudo apt-get install -y build-essential wget libncurses5-dev libgnutls-dev
rm -rf emacs*
wget http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.xz
tar xf emacs*
cd emacs*
./configure
make
make install
