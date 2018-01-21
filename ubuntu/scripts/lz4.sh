#!/bin/bash

# lz4
cd /tmp
rm -rf lz4*
curl -L https://github.com/lz4/lz4/tarball/7bb64ff | tar zx
cd lz4*
make
mv -f lz4 /usr/local/bin

# xxhash
cd /tmp
rm -rf nathants*
curl -L https://github.com/nathants/xxHash/tarball/fb1f4a4 | tar zx
cd nathants*
make
mv -f xxhsum /usr/local/bin
