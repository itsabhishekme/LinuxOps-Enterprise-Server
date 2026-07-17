#!/bin/bash

################################################################################
# LinuxOps Enterprise Server
# File: scripts/reports/system-report.sh
# Description: Generate Complete Linux System Report
# Author: Abhishek Shrivastava
################################################################################

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

REPORT_DIR="$PROJECT_ROOT/reports"
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$REPORT_DIR"
mkdir -p "$LOG_DIR"

REPORT_FILE="$REPORT_DIR/system-report-$(date +%Y-%m-%d_%H-%M-%S).txt"
LATEST_REPORT="$REPORT_DIR/system-report.txt"
LOG_FILE="$LOG_DIR/server.log"

line() {
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '='
}

section() {
    echo ""
    line
    echo "$1"
    line
}

write() {
    echo "$1" | tee -a "$REPORT_FILE"
}

exec > >(tee "$REPORT_FILE") 2>&1

line
echo "LinuxOps Enterprise Server"
echo "Complete System Administration Report"
echo "Generated : $(date)"
echo "Hostname  : $(hostname)"
echo "User      : $(whoami)"
echo "Kernel    : $(uname -r)"
echo "OS        : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
line

###############################################################################
section "SYSTEM INFORMATION"

echo "Hostname            : $(hostname)"
echo "Current User        : $(whoami)"
echo "Current Directory   : $(pwd)"
echo "Kernel Version      : $(uname -r)"
echo "Architecture        : $(uname -m)"
echo "Operating System    : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
echo "System Uptime"
uptime

###############################################################################
section "CPU INFORMATION"

if command -v lscpu >/dev/null 2>&1; then
    lscpu
else
    cat /proc/cpuinfo
fi

###############################################################################
section "MEMORY INFORMATION"

free -h

###############################################################################
section "DISK USAGE"

df -h

###############################################################################
section "BLOCK DEVICES"

lsblk

###############################################################################
section "TOP MEMORY PROCESSES"

ps -eo pid,user,%mem,%cpu,comm --sort=-%mem | head -15

###############################################################################
section "TOP CPU PROCESSES"

ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -15

###############################################################################
section "LOGGED IN USERS"

who

###############################################################################
section "SYSTEM LOAD"

uptime

###############################################################################
section "NETWORK INFORMATION"

ip addr show

###############################################################################
section "ROUTING TABLE"

ip route

###############################################################################
section "LISTENING PORTS"

ss -tulpn

###############################################################################
section "FIREWALL STATUS"

if command -v ufw >/dev/null 2>&1
then
    sudo ufw status verbose
else
    echo "UFW not installed."
fi

###############################################################################
section "NGINX STATUS"

if systemctl list-unit-files | grep -q nginx
then
    systemctl status nginx --no-pager
else
    echo "Nginx not installed."
fi

###############################################################################
section "SAMBA STATUS"

if systemctl list-unit-files | grep -q smbd
then
    systemctl status smbd --no-pager
else
    echo "Samba not installed."
fi

###############################################################################
section "SSH STATUS"

systemctl status ssh --no-pager

###############################################################################
section "DISK INODES"

df -i

###############################################################################
section "MOUNTED FILESYSTEMS"

mount

###############################################################################
section "CRON JOBS"

crontab -l 2>/dev/null || echo "No user cron jobs."

###############################################################################
section "INSTALLED PACKAGE COUNT"

if command -v dpkg >/dev/null 2>&1
then
    dpkg -l | wc -l
fi

###############################################################################
section "RUNNING SERVICES"

systemctl list-units --type=service --state=running

###############################################################################
section "FAILED SERVICES"

systemctl --failed

###############################################################################
section "LAST LOGIN"

last -a | head -15

###############################################################################
section "CURRENT ENVIRONMENT"

env

###############################################################################
section "SYSTEM DATE"

date

###############################################################################
section "PROJECT LOG FILES"

if [ -d "$LOG_DIR" ]
then
    ls -lh "$LOG_DIR"
fi

###############################################################################
section "PROJECT REPORT FILES"

ls -lh "$REPORT_DIR"

###############################################################################
section "BACKUP DIRECTORY"

if [ -d "$PROJECT_ROOT/backups" ]
then
    du -sh "$PROJECT_ROOT/backups"
    ls -R "$PROJECT_ROOT/backups"
fi

###############################################################################
section "SHARED FOLDERS"

if [ -d "$PROJECT_ROOT/shares" ]
then
    ls -R "$PROJECT_ROOT/shares"
fi

###############################################################################
section "PROJECT STRUCTURE"

if command -v tree >/dev/null 2>&1
then
    tree "$PROJECT_ROOT"
else
    find "$PROJECT_ROOT"
fi

###############################################################################
section "SUMMARY"

CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print 100-$8}')
MEMORY_USED=$(free -h | awk '/Mem:/ {print $3}')
MEMORY_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $5}')

echo "CPU Usage      : ${CPU_USAGE}%"
echo "Memory Usage   : ${MEMORY_USED} / ${MEMORY_TOTAL}"
echo "Disk Usage     : ${DISK_USED}"
echo "Hostname       : $(hostname)"
echo "Generated At   : $(date)"

line
echo "Report Completed Successfully"
line

cp "$REPORT_FILE" "$LATEST_REPORT"

echo "$(date) : System report generated successfully." >> "$LOG_FILE"

exit 0