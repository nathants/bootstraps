#!/bin/bash
set -xeuo pipefail

if ! which set-opt &>/dev/null; then
    curl --fail --no-progress-meter https://raw.githubusercontent.com/nathants/bootstraps/280b3e39a5addca597538548dd9d3e3148a6c3cd/set_opt.sh | sudo tee /usr/bin/set-opt >/dev/null
    sudo chmod +x /usr/bin/set-opt
fi

sudo mkdir -p /etc/sysctl.d
set-opt /etc/sysctl.d/99-sysctl.conf 'fs.pipe-max-size '            '= 5242880'
set-opt /etc/sysctl.d/99-sysctl.conf 'fs.file-max '                 '= 3240674'
set-opt /etc/sysctl.d/99-sysctl.conf 'fs.inotify.max_user_watches ' '= 3240674'
set-opt /etc/sysctl.d/99-sysctl.conf 'kernel.pid_max '              '= 4194303'
set-opt /etc/sysctl.d/99-sysctl.conf 'net.core.somaxconn '          '= 8192'

sudo mkdir -p /etc/security
set-opt /etc/security/limits.conf '* - nofile '     '3240674'
set-opt /etc/security/limits.conf '* - memlock '    'unlimited'
set-opt /etc/security/limits.conf '* - nproc '      '32768'
set-opt /etc/security/limits.conf '* - as '         'unlimited'
set-opt /etc/security/limits.conf '* hard core '    '0'
set-opt /etc/security/limits.conf 'root - nofile '  '3240674'
set-opt /etc/security/limits.conf 'root - memlock ' 'unlimited'
set-opt /etc/security/limits.conf 'root - nproc '   '32768'
set-opt /etc/security/limits.conf 'root - as '      'unlimited'
set-opt /etc/security/limits.conf 'root hard core ' '0'

sudo sysctl --system # apply without reboot
