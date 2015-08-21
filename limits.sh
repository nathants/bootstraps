#!/bin/bash
set -e

set_opt() {
    opt=$1
    dst=$2
    if grep "$opt" $dst >/dev/null; then
        echo $dst already has \"$opt\"
    else
        echo "$opt" | sudo tee -a $dst >/dev/null
        echo added \"$opt\" to $dst
    fi
}

set_opt 'fs.file-max = 120000' /etc/sysctl.conf
set_opt 'fs.inotify.max_user_watches = 120000' /etc/sysctl.conf
set_opt '* - nofile 120000' /etc/security/limits.conf
