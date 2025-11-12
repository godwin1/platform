#!/bin/bash
# Complete System Health Monitoring Script
# Author: [Your Name]
# Date: $(date +%Y-%m-%d)

# Configuration - Automatically use home directory if can't write to /var/log
if [ -w "/var/log" ]; then
    LOG_DIR="/var/log"
else
    LOG_DIR="$HOME/logs"
    mkdir -p "$LOG_DIR"
fi

LOG_FILE="$LOG_DIR/health-monitor.log"
ALERT_EMAIL="your-email@example.com"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Services to monitor
CRITICAL_SERVICES=("ssh" "cron")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check CPU usage
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    CPU_INT=${CPU_USAGE%.*}
    
    if [ "$CPU_INT" -gt "$CPU_THRESHOLD" ]; then
        echo -e "${RED}✗ CPU: ${CPU_USAGE}% (Threshold: ${CPU_THRESHOLD}%)${NC}"
        log_message "ALERT: CPU usage is ${CPU_USAGE}%"
        return 1
    else
        echo -e "${GREEN}✓ CPU: ${CPU_USAGE}%${NC}"
        log_message "OK: CPU usage is ${CPU_USAGE}%"
        return 0
    fi
}

# Function to check memory usage
check_memory() {
    MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    
    if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
        echo -e "${RED}✗ Memory: ${MEMORY_USAGE}% (Threshold: ${MEMORY_THRESHOLD}%)${NC}"
        log_message "ALERT: Memory usage is ${MEMORY_USAGE}%"
        return 1
    else
        echo -e "${GREEN}✓ Memory: ${MEMORY_USAGE}%${NC}"
        log_message "OK: Memory usage is ${MEMORY_USAGE}%"
        return 0
    fi
}

# Function to check disk usage
check_disk() {
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo -e "${RED}✗ Disk: ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)${NC}"
        log_message "ALERT: Disk usage is ${DISK_USAGE}%"
        return 1
    else
        echo -e "${GREEN}✓ Disk: ${DISK_USAGE}%${NC}"
        log_message "OK: Disk usage is ${DISK_USAGE}%"
        return 0
    fi
}

# Function to check services
check_services() {
    SERVICES_DOWN=0
    
    for SERVICE in "${CRITICAL_SERVICES[@]}"; do
        if systemctl is-active --quiet "$SERVICE"; then
            echo -e "${GREEN}✓ Service: $SERVICE is running${NC}"
            log_message "OK: $SERVICE is running"
        else
            echo -e "${RED}✗ Service: $SERVICE is DOWN${NC}"
            log_message "ALERT: $SERVICE is DOWN"
            SERVICES_DOWN=$((SERVICES_DOWN + 1))
        fi
    done
    
    return $SERVICES_DOWN
}

# Function to check network connectivity
check_network() {
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Network: Connected${NC}"
        log_message "OK: Network connectivity verified"
        return 0
    else
        echo -e "${RED}✗ Network: Disconnected${NC}"
        log_message "ALERT: Network connectivity failed"
        return 1
    fi
}

# Main execution
echo "=========================================="
echo "    System Health Check"
echo "    $(date '+%Y-%m-%d %H:%M:%S')"
echo "    Log file: $LOG_FILE"
echo "=========================================="
echo ""

log_message "=== Starting health check ==="

# Run all checks
ISSUES=0

check_cpu || ((ISSUES++))
check_memory || ((ISSUES++))
check_disk || ((ISSUES++))
check_services || ((ISSUES++))
check_network || ((ISSUES++))

echo ""
echo "=========================================="
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}All checks passed! System is healthy.${NC}"
    log_message "=== Health check completed: ALL OK ==="
else
    echo -e "${YELLOW}Found $ISSUES issue(s) that need attention.${NC}"
    log_message "=== Health check completed: $ISSUES ISSUES FOUND ==="
fi
echo "=========================================="
