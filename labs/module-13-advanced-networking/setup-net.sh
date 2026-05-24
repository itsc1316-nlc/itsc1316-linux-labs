#!/usr/bin/env bash
#
# setup-net.sh  —  Modules 9 & 13: Advanced Network Configuration
#
# Run this INSIDE your labvm with sudo, AFTER you have launched the second
# VM (see the lab instructions):
#     sudo bash setup-net.sh
#
# It plants a broken name-resolution scenario: a /etc/hosts entry that maps
# the name "fileserver" to the WRONG IP address. Your job in the lab is to
# diagnose that this is a name-resolution problem (not a connectivity
# problem) and correct the mapping.
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run with sudo:  sudo bash setup-net.sh"
  exit 1
fi

MARKER="# itsc1316-fileserver"

echo "[setup] Planting a misconfigured hosts entry for 'fileserver'..."

# The address we plant must be guaranteed unreachable. 192.0.2.0/24 is the
# RFC 5737 TEST-NET-1 documentation range — it is reserved and won't collide
# with the student's home/campus/VPN LAN the way an ad-hoc 10.x.x.x might.
BOGUS_IP="192.0.2.123"

# Make the script re-runnable: drop any prior lab marker AND any leftover
# bogus line (in case the student removed the marker while editing /etc/hosts
# by hand).
sed -i "/${MARKER}/d" /etc/hosts
sed -i "/^${BOGUS_IP}[[:space:]].*fileserver/d" /etc/hosts

# Add a deliberately WRONG mapping (an unreachable address).
echo "${BOGUS_IP}    fileserver    ${MARKER}" >> /etc/hosts

# Drop a starter evidence-report template (idempotent — re-running leaves your
# in-progress work alone). The check script verifies this file's hostname +
# placeholders, so it has to live in the invoking user's home directory.
LAB_USER="${SUDO_USER:-ubuntu}"
LAB_HOME="$(getent passwd "$LAB_USER" | cut -d: -f6)"
REPORT="${LAB_HOME}/module13-network-writeup.txt"
if [[ ! -s "$REPORT" ]]; then
  cat > "$REPORT" <<EOF
=== Module 13 Network Writeup ===
Hostname (paste output of \`hostname\`):
This VM's IP (from \`ip a\`):
The fileserver VM's IP (from \`multipass list\`):
Date:

(Fill this file in as you work the lab. See the README "Written Component"
section for the prompts to paste at the bottom.)
EOF
  chown "$LAB_USER":"$LAB_USER" "$REPORT"
  echo "[setup] Starter writeup dropped at: $REPORT"
fi

echo
echo "[setup] Done. Your /etc/hosts now claims 'fileserver' lives at"
echo "        ${BOGUS_IP}, which is wrong. Use the lab instructions to"
echo "        investigate and fix it."
echo "        Grade yourself with:  bash check-net.sh"
