#!/bin/bash
# Simple system information script

echo "====== SYSTEM INFORMATION ======"
echo ""
echo "Hostname: $(hostname)"
echo "Operating System: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo ""
echo "====== RESOURCE USAGE ======"
echo ""
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
echo ""
echo "Memory Usage:"
free -m | awk 'NR==2{printf "Used: %sMB (%.2f%%)\n", $3,$3*100/$2 }'
echo ""
echo "Disk Usage:"
df -h | grep '^/dev/' | awk '{ print $1 ": " $5 " used" }'
echo ""
echo "====== NETWORK ======"
echo ""
echo "IP Address: $(hostname -I | awk '{print $1}')"
echo ""
echo "Script executed at: $(date)"
