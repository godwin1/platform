#!/bin/bash
# Log analyzer - finds errors and warnings in log files

LOG_FILE=${1:-/var/log/syslog}  # Use first argument or default to syslog

echo "Analyzing log file: $LOG_FILE"
echo "================================"
echo ""

# Count total lines
TOTAL_LINES=$(wc -l < "$LOG_FILE")
echo "Total lines: $TOTAL_LINES"

# Count errors
ERROR_COUNT=$(grep -ci "error" "$LOG_FILE")
echo "Errors: $ERROR_COUNT"

# Count warnings
WARNING_COUNT=$(grep -ci "warning" "$LOG_FILE")
echo "Warnings: $WARNING_COUNT"

echo ""
echo "Last 5 errors:"
echo "---------------"
grep -i "error" "$LOG_FILE" | tail -5

echo ""
echo "Last 5 warnings:"
echo "---------------"
grep -i "warning" "$LOG_FILE" | tail -5
