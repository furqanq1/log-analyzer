#!/bin/bash
# Rich system report -> /opt/log-analyzer/reports/latest.txt
set -e

REPORT_DIR="/opt/log-analyzer/reports"
LOGFILE="/opt/log-analyzer/logs/app.log"
LATEST="$REPORT_DIR/latest.txt"

# Ensure paths exist
mkdir -p "$REPORT_DIR"
[[ -f "$LOGFILE" ]] || touch "$LOGFILE"

# Start fresh
: > "$LATEST"

# ---- Helpers (no complex quoting) ----
echo_sec () { echo "==================[ $1 ]==================" >> "$LATEST"; }
append ()   { "$@" >> "$LATEST" 2>&1 || true; echo >> "$LATEST"; }

# Header
{
  echo "************ RICH REPORT ************"
  echo "Generated at: $(date '+%F %T %Z')"
  echo
} >> "$LATEST"

# HOST / OS / KERNEL
echo_sec "HOST / OS / KERNEL"
append bash -lc 'hostnamectl'
append bash -lc 'printf "OS: "; grep -E "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d \"'
append bash -lc 'printf "Kernel: "; uname -r'

# UPTIME / USERS
echo_sec "UPTIME / USERS"
append bash -lc 'uptime'
append bash -lc 'who'

# CPU / MEMORY / LOAD
echo_sec "CPU / MEMORY / LOAD"
append bash -lc 'free -m'
append bash -lc 'top -b -n1 | head -n 10'

# DISK + INODES + TOP SPACE in /var
echo_sec "DISK (df -h) + INODES (df -i)"
append bash -lc 'df -h'
append bash -lc 'df -i'

echo_sec "TOP SPACE IN /var (top 10)"
append bash -lc 'sudo du -sh /var/* 2>/dev/null | sort -hr | head -n 10'

# NETWORK
echo_sec "NETWORK: IP / ROUTES / DNS"
append bash -lc 'ip a'
append bash -lc 'ip route'
append bash -lc 'grep -E "nameserver|search" /etc/resolv.conf || true'

# PORTS
echo_sec "OPEN/LISTENING PORTS (ss -tulnp)"
append bash -lc 'sudo ss -tulnp'

# TOP PROCESSES
echo_sec "TOP PROCESSES (CPU / MEM)"
append bash -lc 'echo "[Top 10 by CPU]"; ps aux --sort=-%cpu | head -n 11'
append bash -lc 'echo "[Top 10 by MEM]"; ps aux --sort=-%mem | head -n 11'

# SERVICES
echo_sec "SERVICES STATUS (nginx / sshd)"
append bash -lc 'sudo systemctl status nginx --no-pager'
append bash -lc 'sudo systemctl status sshd  --no-pager'

# JOURNAL ERRORS/WARNINGS
echo_sec "JOURNAL (last 200 scanned) - errors/warnings"
append bash -lc 'sudo journalctl -n 200 | grep -Ei "error|failed|critical|warning" | tail -n 50'

# SSHD ACCEPTED / FAILED
echo_sec "SSHD ACCEPTED / FAILED (last 20 each)"
append bash -lc 'echo "[ACCEPTED]"; sudo journalctl -u sshd | grep -i "Accepted" | tail -n 20'
append bash -lc 'echo; echo "[FAILED]"; sudo journalctl -u sshd | grep -i "Failed" | tail -n 20'

# DMESG
echo_sec "DMESG (last 50)"
append bash -lc 'dmesg | tail -n 50'

# APP LOG SUMMARY
echo_sec "APP LOG SUMMARY ($LOGFILE)"
append bash -lc 'echo "[ERRORS]";   grep -i "error"   "'"$LOGFILE"'" || echo "None"'
append bash -lc 'echo; echo "[WARNINGS]"; grep -i "warning" "'"$LOGFILE"'" || echo "None"'
append bash -lc 'echo; printf "[INFO COUNT] "; grep -i "info" "'"$LOGFILE"'" | wc -l'
append bash -lc 'echo; echo "[Last 10 lines]"; tail -n 10 "'"$LOGFILE"'"'

# Footer
{
  echo
  echo "************ END ************"
} >> "$LATEST"

chmod 644 "$LATEST"
