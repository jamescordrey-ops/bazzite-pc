#!/bin/bash
set -ouex pipefail

# Copy the system_files tree into the image root.
cp -avf "/ctx/system_files"/. /

# Helpers must be executable no matter what git recorded.
chmod 755 /usr/libexec/muse-firstboot.sh /usr/bin/muse-finish /usr/bin/muse-setup-launcher
chmod 644 /etc/ssh/authorized_keys

# Remote access: sshd key-only via the system-level authorized_keys,
# tailscaled enabled but never joined from the image (join happens in
# muse-finish, with the owner's own key, or not at all: LAN-only is a
# supported end state).
systemctl enable sshd.service
systemctl enable tailscaled.service
systemctl enable muse-firstboot.service
