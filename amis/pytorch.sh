#!/bin/bash
set -euo pipefail

if ! which aws-ec2-new &>/dev/null; then
    echo fatal: need to install https://github.com/nathants/cli-aws
    exit 1
fi

id=$(aws-ec2-new bake-ami \
        --type p3.2xlarge \
        --ami arch \
        --spot 0 \
        --gigs 32)

trap "aws-ec2-ls -s running $id && aws-ec2-rm -y $id" EXIT

packages='
    git
    htop
    man
    rsync
    vim
    nvidia-dkms
    python-pytorch-cuda
'

pips='
    argh
    awscli
    glances
    ipdb
    ipython
    matplotlib
    numpy
    opencv-python
    pandas
    pillow
    scikit-image
    scikit-learn
    tensorboard
    torchvision
    tqdm
'

aws-ec2-ssh $id -yc "

    echo
    echo install packages
    sudo pacman -Syu --noconfirm --noprogress
    sudo pacman -S --needed --noconfirm --noprogress $(echo $packages)

    echo
    echo install pips
    sudo python -m ensurepip
    sudo python -m pip install -U pip wheel
    sudo python -m pip install $(echo $pips)

"

aws-ec2-reboot $id -y
sleep 15
aws-ec2-wait-for-state $id -y
ami=$(aws-ec2-ami $id -y --name pytorch)
aws-ec2-rm -y $id
echo build ami: $ami
