#!/bin/bash
set -ouex pipefail

# Copy the system_files tree into the image root.
cp -avf "/ctx/system_files"/. /

# Helpers must be executable no matter what git recorded.
chmod 755 /usr/libexec/muse-firstboot.sh /usr/bin/muse-finish /usr/bin/muse-setup-launcher
chmod 644 /etc/ssh/authorized_keys

# Razer keypad support: the base image ships the OpenRazer userspace and
# kernel module but not the daemon, and its userspace sits one packaging
# revision behind Terra, which blocks every runtime install route
# (rpm-ostree cannot replace the baked packages). Take the whole
# userspace set from Terra in one build-time transaction and enable the
# daemon for all users. The kernel module only requires
# openrazer-kmod-common >= 3.12.4, which the newer userspace satisfies.
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/terra.repo
dnf install -y openrazer openrazer-daemon python3-openrazer
systemctl --global enable openrazer-daemon.service

# Remote access: sshd key-only via the system-level authorized_keys,
# tailscaled enabled but never joined from the image (join happens in
# muse-finish, with the owner's own key, or not at all: LAN-only is a
# supported end state).
systemctl enable sshd.service
systemctl enable tailscaled.service
systemctl enable muse-firstboot.service
