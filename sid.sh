#!/bin/bash
set -eou pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    echo "must run as root." >&2
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    echo "missing /etc/os-release." >&2
    exit 1
fi

. /etc/os-release

if [[ "${ID:-}" != "debian" ]]; then
    echo "requires debian." >&2
    exit 1
fi

sources_dir="/etc/apt/sources.list.d"
sources_file="${sources_dir}/debian.sources"
backup_dir="/root/apt-sources-backup-$(date +%s)"

install -d -m 0755 "${sources_dir}"
install -d -m 0700 "${backup_dir}"

echo "backing up legacy sources to ${backup_dir}" >&2

if [[ -f "${sources_file}" ]]; then
    mv "${sources_file}" "${backup_dir}/"
fi

for path in /etc/apt/sources.list /etc/apt/sources.list.*; do
    if ! [[ -d "${path}" ]]; then
        mv "${path}" "${backup_dir}/"
    fi
done

if [[ -d "${sources_dir}" ]]; then
    while IFS= read -r -d '' path; do
        mv "${path}" "${backup_dir}/"
    done < <(find "${sources_dir}" -maxdepth 1 -type f -name '*.list*' -print0)
fi

cat <<'SRC' > "${sources_file}"
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: sid
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
SRC

chmod 0644 "${sources_file}"

echo "wrote ${sources_file}" >&2

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get --yes dist-upgrade
apt-get --yes autoremove
