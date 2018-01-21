#!/bin/bash
set -eu

echo "deb http://binaries.erlang-solutions.com/debian $(lsb_release -s -c) contrib" | sudo tee /etc/apt/sources.list.d/erlang.list
wget -O - http://binaries.erlang-solutions.com/debian/erlang_solutions.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y esl-erlang
