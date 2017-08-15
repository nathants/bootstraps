#!/bin/bash
set -eu
mkdir -p ~/opt
cd ~/opt
sudo apt-get install -y build-essential wget libncurses5-dev libgnutls-dev
rm -rf emacs*
# wget http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.xz
wget http://ftp.gnu.org/gnu/emacs/emacs-25.2.tar.xz
wget http://ftp.gnu.org/gnu/emacs/emacs-25.2.tar.xz.sig
gpg --verify emacs*.sig
tar xf emacs*.xz
cd emacs*
./configure --with-x-toolkit=no --with-xpm=no --with-jpeg=no --with-png=no --with-gif=no --with-tiff=no
make
make install
