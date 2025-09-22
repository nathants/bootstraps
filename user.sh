#!/bin/bash
set -eou pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    echo "must run as root." >&2
    exit 1
fi

if [[ "$#" -ne 1 ]]; then
    echo "usage: $0 <username>" >&2
    exit 1
fi

user_name="$1"

if id -u "${user_name}" >/dev/null 2>&1; then
    echo "user ${user_name} already exists." >&2
    exit 1
fi

if [[ ! -f /root/.ssh/authorized_keys ]]; then
    echo "missing /root/.ssh/authorized_keys." >&2
    exit 1
fi

useradd --create-home --shell /bin/bash "${user_name}"

if [[ ! -d /etc/sudoers.d ]]; then
    install -d -m 755 /etc/sudoers.d
fi

sudoers_path="/etc/sudoers.d/${user_name}"
sudoers_entry="${user_name} ALL=(ALL) NOPASSWD:ALL"

if [[ -e "${sudoers_path}" ]]; then
    echo "sudoers entry already exists for ${user_name}." >&2
    exit 1
fi

printf "%s\n" "${sudoers_entry}" > "${sudoers_path}"
chmod 440 "${sudoers_path}"
visudo -cf /etc/sudoers >/dev/null


install -d -m 700 "/home/${user_name}/.ssh"
chmod 700 "/home/${user_name}"

mv /root/.ssh/authorized_keys "/home/${user_name}/.ssh/authorized_keys"
chmod 600 "/home/${user_name}/.ssh/authorized_keys"
chown -R "${user_name}:${user_name}" "/home/${user_name}/.ssh"

passwd --lock root
for name in $(cd /home && ls); do
    echo lock user: ${name}
    passwd --lock ${name}
done
