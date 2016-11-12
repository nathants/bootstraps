#!/bin/bash
set -eu

bootstraps=$(dirname $0)

bash $bootstraps/set_opt.sh /etc/sysctl.conf 'fs.file-max' ' = 120000'
bash $bootstraps/set_opt.sh /etc/sysctl.conf 'fs.inotify.max_user_watches' ' = 120000'

bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - nofile' ' 120000'
bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - memlock' ' unlimited'
bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - nproc' ' 32768'
bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - as' ' unlimited'

bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - nofile' ' 120000'
bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - memlock' ' unlimited'
bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - nproc' ' 32768'
bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - as' ' unlimited'
