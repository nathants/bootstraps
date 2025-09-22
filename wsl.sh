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
    bash-completion \
    bsdmainutils \
    clang \
    clang-format \
    clang-tidy \
    clangd \
    cmake \
    containerd.io \
    curl \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    emacs-nox \
    expect \
    gcc \
    gdb \
    git-lfs \
    golang \
    gpg \
    htop \
    jq \
    libgoogle-perftools-dev \
    liblz4-dev \
    libpipewire-0.3-dev \
    libsdl2-compat-dev \
    libsndfile1-dev \
    libsodium-dev \
    libyaml-cpp-dev \
    lldb \
    make \
    mold \
    npm \
    openssh-server \
    pinentry-gtk2 \
    pipewire-bin \
    pipewire-pulse \
    pkg-config \
    pulseaudio-utils \
    python3-pyqt5 \
    python3-virtualenv \
    ripgrep \
    rsync \
    silversearcher-ag \
    tmux \
    tree \
    unzip \
    uuid-runtime \
    vim \
    wget \
    wireguard-tools \
    zip

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
