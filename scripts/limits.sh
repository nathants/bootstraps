#!/bin/bash
set -eu

bootstraps=$(dirname $0)

bash $bootstraps/set_opt.sh /etc/sysctl.conf 'fs.file-max' ' = 120000'
bash $bootstraps/set_opt.sh /etc/sysctl.conf 'fs.inotify.max_user_watches' ' = 120000'
bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - nofile' ' 120000'
