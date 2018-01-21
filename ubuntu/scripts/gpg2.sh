#!/bin/bash
# ---------
# Script to build and install GnuPG 2.2.x
# https://gist.github.com/vt0r/a2f8c0bcb1400131ff51
set -xeuo pipefail
sudo apt-get update
sudo apt-get -y install build-essential bzip2 gettext gnutls-bin libbz2-dev libgnutls-dev libgnutls28-dev libldap2-dev libncurses5-dev libsqlite3-dev make texinfo zlib1g-dev
sudo rm -rf /var/src/gnupg22
sudo mkdir -p /var/src/gnupg22
sudo chmod ugo+rw /var/src/gnupg22
cd /var/src/gnupg22
gpg --list-keys
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 249B39D24F25E3B6 04376F3EE0856959 2071B08A33BD3F06 8A861B1C7EFD60D9
wget -c https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.27.tar.gz
wget -c https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.27.tar.gz.sig
wget -c https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.2.tar.gz
wget -c https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.2.tar.gz.sig
wget -c https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.1.tar.bz2
wget -c https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.1.tar.bz2.sig
wget -c https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2
wget -c https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2.sig
wget -c https://www.gnupg.org/ftp/gcrypt/npth/npth-1.5.tar.bz2
wget -c https://www.gnupg.org/ftp/gcrypt/npth/npth-1.5.tar.bz2.sig
wget -c https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.1.0.tar.bz2
wget -c https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.1.0.tar.bz2.sig
wget -c https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.4.tar.bz2
wget -c https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.4.tar.bz2.sig
gpg --verify libgpg-error-1.27.tar.gz.sig && tar -xzf libgpg-error-1.27.tar.gz
gpg --verify libgcrypt-1.8.2.tar.gz.sig && tar -xzf libgcrypt-1.8.2.tar.gz
gpg --verify libassuan-2.5.1.tar.bz2.sig && tar -xjf libassuan-2.5.1.tar.bz2
gpg --verify libksba-1.3.5.tar.bz2.sig && tar -xjf libksba-1.3.5.tar.bz2
gpg --verify npth-1.5.tar.bz2.sig && tar -xjf npth-1.5.tar.bz2
gpg --verify pinentry-1.1.0.tar.bz2.sig && tar -xjf pinentry-1.1.0.tar.bz2
gpg --verify gnupg-2.2.4.tar.bz2.sig && tar -xjf gnupg-2.2.4.tar.bz2
(cd libgpg-error-1.27/ && ./configure && make && make install)
(cd libgcrypt-1.8.2 && ./configure && make && make install)
(cd libassuan-2.5.1 && ./configure && make && make install)
(cd libksba-1.3.5 && ./configure && make && make install)
(cd npth-1.5 && ./configure && make && make install)
(cd pinentry-1.1.0 && ./configure --enable-pinentry-curses --disable-pinentry-qt4 && make && make install)
(cd gnupg-2.2.4 && ./configure && make && make install )
echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/gpg2.conf
sudo ldconfig -v
