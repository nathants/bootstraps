#!/bin/bash
set -euo pipefail

if ! which set-opt &>/dev/null; then
    echo '
        fatal: no set-opt, download and chmod:
        >> curl https://raw.githubusercontent.com/nathants/bootstraps/master/bin/set_opt.sh > /usr/local/bin/set-opt
        >> chmod +x /usr/local/bin/set-opt
    '
    exit 1
fi

mkdir -p /etc/sysctl.d
set-opt /etc/sysctl.d/99-sysctl.conf 'fs.pipe-max-size' ' = 5242880'
set-opt /etc/sysctl.d/99-sysctl.conf 'fs.file-max' ' = 120000'
set-opt /etc/sysctl.d/99-sysctl.conf 'fs.inotify.max_user_watches' ' = 120000'
set-opt /etc/sysctl.d/99-sysctl.conf 'kernel.pid_max' ' = 4194303'
set-opt /etc/sysctl.d/99-sysctl.conf 'net.core.somaxconn' ' = 8192'

set-opt /etc/security/limits.conf '* - nofile' ' 120000'
set-opt /etc/security/limits.conf '* - memlock' ' unlimited'
set-opt /etc/security/limits.conf '* - nproc' ' 32768'
set-opt /etc/security/limits.conf '* - as' ' unlimited'

set-opt /etc/security/limits.conf 'root - nofile' ' 120000'
set-opt /etc/security/limits.conf 'root - memlock' ' unlimited'
set-opt /etc/security/limits.conf 'root - nproc' ' 32768'
set-opt /etc/security/limits.conf 'root - as' ' unlimited'
