#!/usr/bin/env bash
#
# setup-users.sh  —  Module 6: Users, Ownership, and Permissions
#
# Builds the lab scenario inside your Multipass VM. Run it ONCE with sudo:
#     sudo bash setup-users.sh
#
# It creates a shared "salesteam" group, two extra users, a /salesteam
# directory, and a report-generating script with deliberately wrong
# permissions for you to fix.
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run with sudo:  sudo bash setup-users.sh"
  exit 1
fi

echo "[setup] Creating the salesteam group..."
groupadd -f salesteam

echo "[setup] Creating users avery and jordan..."
for u in avery jordan; do
  if ! id "$u" &>/dev/null; then
    useradd -m -s /bin/bash -G salesteam "$u"
    echo "${u}:lab6-${u}" | chpasswd
  fi
done

# Make sure the invoking (default) user is in the salesteam group too,
# since that is the account the student works from. Defaults to 'ubuntu' on
# Multipass; works on cloud-fallback VMs whose default user differs.
LAB_USER="${SUDO_USER:-ubuntu}"
usermod -aG salesteam "$LAB_USER"

echo "[setup] Building /salesteam directory and seed files..."
mkdir -p /salesteam
# Start ownership WRONG on purpose: owned by root, so the student must fix it.
chown root:root /salesteam
chmod 755 /salesteam

# Drop a report-generating script with the WRONG permissions (not executable,
# world-readable). The student must lock it down and make it run.
cat > /salesteam/generate_reports.sh <<'EOF'
#!/usr/bin/env bash
# Generates three quarterly sales reports in the current directory.
for q in Q1 Q2 Q3; do
  echo "Sales report for ${q} - generated $(date)" > "/salesteam/${q}-report.xls"
done
echo "Three quarterly reports created."
EOF

# Wrong on purpose: not executable, owned by root.
chown root:root /salesteam/generate_reports.sh
chmod 644 /salesteam/generate_reports.sh

# Drop a starter evidence-report template (idempotent — re-running leaves your
# in-progress work alone). The check script verifies this file's hostname +
# placeholders, so it has to live somewhere the student can write to.
LAB_HOME="$(getent passwd "$LAB_USER" | cut -d: -f6)"
REPORT="${LAB_HOME}/module6-permissions-report.txt"
if [[ ! -s "$REPORT" ]]; then
  cat > "$REPORT" <<EOF
=== Module 6 Evidence Report ===
Hostname:
Investigator:
Date:

(Fill this file in as you work the lab. See the README "Written Component"
section for the prompts to paste at the bottom.)
EOF
  chown "$LAB_USER":"$LAB_USER" "$REPORT"
  echo "[setup] Starter report dropped at: $REPORT"
fi

echo
echo "[setup] Done. The scenario is intentionally MISCONFIGURED."
echo "        Your job is described in the lab instructions."
echo "        When finished, grade yourself with:  bash check-users.sh"
