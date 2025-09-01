#!/bin/bash
set -xeou pipefail

cd $(dirname $0)

echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null
sudo chmod 440 /etc/sudoers.d/$USER

sudo tee /etc/apt/sources.list > /dev/null << 'EOF'
deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
EOF

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" \
     | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    emacs-nox \
    vim \
    clang \
    clang-format \
    clang-tidy \
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
    htop \
    openssh-server \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

sudo groupadd -f docker
sudo usermod -aG docker $USER

sudo systemctl enable docker
sudo systemctl start docker

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
