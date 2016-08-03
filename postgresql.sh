#!/bin/bash
set -e

version=$1
[ -z "$version" ] && echo must specify version && exit 1

echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql-${version}
echo "
# wide open on all ports
local all all trust
host all all 0.0.0.0/0 trust
" | sudo tee /etc/postgresql/${version}/main/pg_hba.conf
echo "listen_addresses='*'" | sudo tee -a /etc/postgresql/${version}/main/postgresql.conf
