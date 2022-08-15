#!/bin/bash
set -euo pipefail

if ! which set-opt &>/dev/null; then
    curl --fail --no-progress-meter https://raw.githubusercontent.com/nathants/bootstraps/master/set_opt.sh | /usr/bin/sudo tee /usr/bin/set-opt >/dev/null
    /usr/bin/sudo chmod +x /usr/bin/set-opt
fi

/usr/bin/sudo mkdir -p /etc/ssh
set-opt /etc/ssh/sshd_config UseDNS                   " no"
set-opt /etc/ssh/sshd_config PasswordAuthentication   " no"
set-opt /etc/ssh/sshd_config Compression              " no"
set-opt /etc/ssh/sshd_config PermitRootLogin          " no"
set-opt /etc/ssh/sshd_config Ciphers                  " chacha20-poly1305@openssh.com"
set-opt /etc/ssh/sshd_config HostKeyAlgorithms        " ssh-ed25519"
set-opt /etc/ssh/sshd_config KexAlgorithms            " curve25519-sha256,curve25519-sha256@libssh.org"
set-opt /etc/ssh/sshd_config MACs                     " hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com"
set-opt /etc/ssh/sshd_config PubkeyAcceptedAlgorithms " ssh-ed25519"
