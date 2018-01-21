#!/bin/bash
set -eu

sudo timedatectl set-timezone Etc/UTC
sudo service cron restart
