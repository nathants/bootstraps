#!/bin/bash
set -euo pipefail

if ! which aws-ec2-new &>/dev/null; then
    echo fatal: need to install https://github.com/nathants/cli-aws
    exit 1
fi

id=$(aws-ec2-new bake-ami \
        --type z1d.large \
        --ami arch \
        --spot 0 \
        --gigs 24)

trap "aws-ec2-ls -s running $id && aws-ec2-rm -y $id" EXIT

packages='
    curl
    entr
    ffmpeg
    gcc
    git
    glances
    htop
    imagemagick
    jq
    lsof
    lz4
    man
    pv
    pypy3
    python-pytorch-cuda
    python3
    rsync
    tree
    vim
'

pips='
    argh
    awscli
    blessings
    cffi
    hashin
    hypothesis
    ipdb
    ipython
    pytest
    pytest-xdist
    python-dateutil
    pytz
    requests
    tornado
    tox
    virtualenv
    yq
    git+https://github.com/nathants/cli-aws
    git+https://github.com/nathants/py-pool
    git+https://github.com/nathants/py-shell
    git+https://github.com/nathants/py-util
    git+https://github.com/nathants/py-web
'

cpython_pips='
    bokeh
    matplotlib
    numpy
    opencv-python
    pandas
    pillow
    scikit-image
    scikit-learn
    tensorboard
    torch
    torchvision
    git+https://github.com/nathants/ptop
'

aws-ec2-ssh $id -yc "

    echo
    echo install packages
    sudo pacman -Syu --noconfirm --noprogress
    sudo pacman -S --needed --noconfirm --noprogress $(echo $packages)

    echo
    echo setup linux limits
    curl -s https://raw.githubusercontent.com/nathants/bootstraps/master/scripts/limits.sh | bash

    echo
    echo install pips
    sudo python -m ensurepip
    sudo python -m pip install -U pip wheel
    sudo python -m pip install $(echo $pips $cpython_pips)

    sudo pypy3 -m ensurepip
    sudo pypy3 -m pip install -U pip wheel
    sudo pypy3 -m pip install $(echo $pips)

"

aws-ec2-reboot $id -y
sleep 15
aws-ec2-wait-for-state $id -y
ami=$(aws-ec2-ami $id -y --name pytorch)
aws-ec2-rm -y $id
echo build ami: $ami
