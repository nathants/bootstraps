#!/bin/bash

# lz4
cd /tmp
rm -rf lz4*
curl -L https://github.com/lz4/lz4/tarball/7bb64ff | tar zx
cd lz4*
make
make install

# xxhash
cd /tmp
rm -rf Cyan4973*
curl -L https://github.com/Cyan4973/xxHash/tarball/88c6ee1 | tar zx
cd Cyan4973*
make
mv xxhsum /usr/local/bin