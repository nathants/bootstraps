#!/bin/bash
set -eu

bootstraps=$(dirname $0)

mkdir -p /etc/sysctl.d
bash $bootstraps/set_opt.sh /etc/sysctl.d/99-sysctl.conf 'fs.pipe-max-size' ' = 5242880'
bash $bootstraps/set_opt.sh /etc/sysctl.d/99-sysctl.conf 'fs.file-max' ' = 120000'
bash $bootstraps/set_opt.sh /etc/sysctl.d/99-sysctl.conf 'fs.inotify.max_user_watches' ' = 120000'
bash $bootstraps/set_opt.sh /etc/sysctl.d/99-sysctl.conf 'kernel.pid_max' ' = 4194303'
bash $bootstraps/set_opt.sh /etc/sysctl.d/99-sysctl.conf 'net.core.somaxconn' ' = 8192'

bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - nofile' ' 120000'
bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - memlock' ' unlimited'
bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - nproc' ' 32768'
bash $bootstraps/set_opt.sh /etc/security/limits.conf '* - as' ' unlimited'

bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - nofile' ' 120000'
bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - memlock' ' unlimited'
bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - nproc' ' 32768'
bash $bootstraps/set_opt.sh /etc/security/limits.conf 'root - as' ' unlimited'
