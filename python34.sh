#!/bin/bash

sudo apt-get update
sudo apt-get install -y python3.4-dev build-essential git python-virtualenv
virtualenv ~/env --python=python3.4
echo 'export PATH=~/env/bin:$PATH' >> ~/.bashrc
