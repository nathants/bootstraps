#!/bin/bash
set -xeou pipefail

cd $(dirname $0)

sudo tee /etc/apt/sources.list > /dev/null << 'EOF'
deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
EOF

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    emacs-nox \
    vim \
    clang \
    cmake \
    bash-completion \
    gcc \
    gdb \
    golang \
    libsodium-dev \
    liblz4-dev \
    lldb \
    make \
    mold \
    npm \
    pkg-config \
    python3-virtualenv \
    rsync \
    ripgrep \
    silversearcher-ag \
    tmux \
    unzip \
    curl \
    wget \
    wireguard-tools \
    zip \
    expect \
    jq \
    uuid-runtime \
    pinentry-curses \
    gpg \
    python3-pyqt5 \
    libsdl2-compat-dev \
    libsndfile1-dev \
    libyaml-cpp-dev \
    libgoogle-perftools-dev \
    libpipewire-0.3-dev \
    pipewire-bin \
    pulseaudio-utils \
    pipewire-pulse \
    tree \
    git-lfs \
    clangd \
    openssh-server

bash limits.sh
bash sshd.sh

mkdir -p ~/.ssh
chmod 700 ~/.ssh
curl -s https://github.com/nathants.keys > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

sudo systemctl enable ssh
sudo systemctl enable ssh

sudo rm -f /etc/profile.d/70-systemd-shell-extra.sh
sudo rm -f /etc/profile.d/80-systemd-osc-context.sh

curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
[ "dade5ae8b0bc1c029d18f260e30be1e89a3b9512bcc2904c038be75e80b02ff4" = $(sha256sum /tmp/win32yank.exe | awk '{print $1}') ]
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/

ip=$(hostname -I | awk '{print $1}')

cat << EOF

forward port: netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=$ip
open firewall: netsh advfirewall firewall add rule name="WSL2 SSH" dir=in action=allow protocol=TCP localport=22

list forwards: netsh interface portproxy show v4tov4
delete forward: netsh interface portproxy delete v4tov4 listenport=22 listenaddress=0.0.0.0

EOF
