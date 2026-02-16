#!/bin/bash
# Rich system report -> /opt/log-analyzer/reports/latest.txt
set -e

REPORT_DIR="/opt/log-analyzer/reports"
LOGFILE="/opt/log-analyzer/logs/app.log"
LATEST="$REPORT_DIR/latest.txt"
TS=$(date "+%F %T")

mkdir -p "$REPORT_DIR"

# Helper: safe run a section (never break report)
section () {
  local title="$1"; shift
  echo "==================[ $title ]==================" 
  { "$@"; } 2>&1 || true
  echo
}

{
  echo "************ LOG ANALYZER – RICH REPORT ************"
  echo "Generated at: $TS"
  echo

  section "HOST / OS / KERNEL" bash -lc 
