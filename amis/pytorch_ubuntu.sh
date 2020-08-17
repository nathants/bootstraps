#!/bin/bash
set -euo pipefail

if ! which aws-ec2-new &>/dev/null; then
    echo fatal: need to install https://github.com/nathants/cli-aws
    exit 1
fi

id=$(aws-ec2-new bake-ami \
        --type p3.2xlarge \
        --ami focal \
        --spot 0 \
        --gigs 32)

trap "aws-ec2-ls -s running $id && aws-ec2-rm -y $id" EXIT

packages='
    build-essential
    git
    htop
    nvidia-cuda-toolkit
    python3-pip
    rsync
    vim
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
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y $(echo $packages)

    echo
    echo install pips
    sudo python3 -m pip install -U pip wheel
    sudo python3 -m pip install $(echo $pips)
    sudo python3 -m pip install torch==1.6.0+cu101 torchvision==0.7.0+cu101 -f https://download.pytorch.org/whl/torch_stable.html

"

aws-ec2-reboot $id -y
sleep 15
aws-ec2-wait-for-state $id -y
ami=$(aws-ec2-ami $id -y --name pytorch-ubuntu)
aws-ec2-rm -y $id
echo build ami: $ami
