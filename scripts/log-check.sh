#!/bin/bash

LOG="logs/app.log"
LATEST="reports/latest.txt"

echo "Report generated at $(date)" > $LATEST
echo "" >> $LATEST

echo "[ERRORS]" >> $LATEST
grep -i "error" $LOG || echo "No errors" >> $LATEST

echo "" >> $LATEST
echo "[WARNINGS]" >> $LATEST
grep -i "warning" $LOG || echo "No warnings" >> $LATEST
