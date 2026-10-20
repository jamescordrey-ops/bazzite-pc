#!/bin/bash
# First-boot helper: keep remote access up until the owner runs the
# finish setup. Idempotent.
set -u
mkdir -p /var/lib/muse
systemctl enable --now tailscaled.service 2>/dev/null || true
systemctl enable --now sshd.service 2>/dev/null || true
exit 0
