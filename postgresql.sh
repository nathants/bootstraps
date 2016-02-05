#!/bin/bash
set -e

echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql-9.5
echo "
# wide open on all ports
local all all trust
local all all trust
host all all 127.0.0.1/32 trust
host all all ::1/128 trust
" | sudo tee /etc/postgresql/9.5/main/pg_hba.conf
sudo -u postgres createuser --superuser $(whoami)
sudo -u postgres createdb $(whoami)
