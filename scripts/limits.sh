#!/bin/bash
set -e

bootstraps=$(dirname $0)
source ${bootstraps}/set_opt.sh

set_opt /etc/sysctl.conf 'fs.file-max' '= 120000'
set_opt /etc/sysctl.conf 'fs.inotify.max_user_watches' '= 120000'
set_opt /etc/security/limits.conf '* - nofile' '120000'
