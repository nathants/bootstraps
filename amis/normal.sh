#!/bin/bash
set -euo pipefail

if ! which aws-ec2-new &>/dev/null; then
    echo fatal: need to install https://github.com/nathants/cli-aws
    exit 1
fi

id=$(aws-ec2-new bake-ami \
        --type i3en.large \
        --ami arch \
        --spot 0 \
        --gigs 8)

trap "aws-ec2-ls -s running $id && aws-ec2-rm -y $id" EXIT

packages='
    curl
    entr
    gcc
    git
    glances
    htop
    jq
    lsof
    lz4
    man
    pypy3
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
    git+https://github.com/nathants/cffi-xxh3
    git+https://github.com/nathants/cli-aws
    git+https://github.com/nathants/py-pool
    git+https://github.com/nathants/py-shell
    git+https://github.com/nathants/py-util
    git+https://github.com/nathants/py-web
'

aws-ec2-ssh $id -yc "

    echo
    echo install packages
    sudo pacman -Syu --noconfirm --noprogress
    sudo pacman -S --needed --noconfirm --noprogress $(echo $packages)

    echo
    echo setup linux limits
    curl -s https://raw.githubusercontent.com/nathants/bootstraps/master/scripts/set_opt.sh | sudo tee /usr/local/bin/set-opt >/dev/null && sudo chmod +x /usr/local/bin/set-opt
    curl -s https://raw.githubusercontent.com/nathants/bootstraps/master/scripts/limits.sh | bash

    echo
    echo install pips
    sudo python -m ensurepip
    sudo python -m pip install -U pip wheel
    sudo python -m pip install $(echo $pips) git+https://github.com/nathants/ptop numpy pandas bokeh matplotlib ipython ipdb

    sudo pypy3 -m ensurepip
    sudo pypy3 -m pip install -U pip wheel
    sudo pypy3 -m pip install $(echo $pips)

    echo
    echo install s4 and bsv
    curl -s https://raw.githubusercontent.com/nathants/s4/master/scripts/install_archlinux.sh | bash

"

aws-ec2-reboot $id -y
sleep 15
aws-ec2-wait-for-state $id -y
ami=$(aws-ec2-ami $id -y --name normal)
aws-ec2-rm -y $id
echo build ami: $ami
