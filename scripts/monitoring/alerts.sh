#!/bin/bash

############################################################
# LinuxOps Enterprise Server
# File: scripts/monitoring/alerts.sh
# Description:
# System Health Alert Script
# Author: Abhishek Shrivastava
############################################################

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
REPORT_DIR="$PROJECT_ROOT/reports"

LOG_FILE="$LOG_DIR/monitor.log"
REPORT_FILE="$REPORT_DIR/security-report.txt"

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90

CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

log() {
    echo "[$CURRENT_TIME] $1" | tee -a "$LOG_FILE"
}

cpu_usage() {
    top -bn1 | awk '/Cpu\(s\)/ {print int($2+$4)}'
}

memory_usage() {
    free | awk '/Mem:/ {printf("%d"), $3/$2*100}'
}

disk_usage() {
    df / | awk 'NR==2 {gsub("%",""); print $5}'
}

network_status() {
    ip link show | grep "state UP" | awk -F': ' '{print $2}'
}

running_services() {

    echo ""
    echo "Running Services"

    systemctl list-units --type=service --state=running \
    | head -20

}

check_cpu() {

    CPU=$(cpu_usage)

    if [ "$CPU" -ge "$CPU_THRESHOLD" ]; then
        log "WARNING : CPU Usage High (${CPU}%)"
    else
        log "CPU Usage Normal (${CPU}%)"
    fi

}

check_memory() {

    MEM=$(memory_usage)

    if [ "$MEM" -ge "$MEMORY_THRESHOLD" ]; then
        log "WARNING : Memory Usage High (${MEM}%)"
    else
        log "Memory Usage Normal (${MEM}%)"
    fi

}

check_disk() {

    DISK=$(disk_usage)

    if [ "$DISK" -ge "$DISK_THRESHOLD" ]; then
        log "WARNING : Disk Usage High (${DISK}%)"
    else
        log "Disk Usage Normal (${DISK}%)"
    fi

}

check_nginx() {

    if systemctl is-active --quiet nginx
    then
        log "Nginx Service Running"
    else
        log "ALERT : Nginx Service Stopped"
    fi

}

check_samba() {

    if systemctl is-active --quiet smbd
    then
        log "Samba Service Running"
    else
        log "ALERT : Samba Service Stopped"
    fi

}

check_firewall() {

    if systemctl is-active --quiet ufw
    then
        log "Firewall Active"
    else
        log "Firewall Inactive"
    fi

}

generate_report() {

cat > "$REPORT_FILE" <<EOF

===================================================
 LinuxOps Enterprise Server Security Report
===================================================

Generated :
$CURRENT_TIME

---------------------------------------------------
CPU Usage
---------------------------------------------------
$(cpu_usage) %

---------------------------------------------------
Memory Usage
---------------------------------------------------
$(memory_usage) %

---------------------------------------------------
Disk Usage
---------------------------------------------------
$(disk_usage) %

---------------------------------------------------
Network Interfaces
---------------------------------------------------
$(network_status)

---------------------------------------------------
Nginx Status
---------------------------------------------------
$(systemctl is-active nginx)

---------------------------------------------------
Samba Status
---------------------------------------------------
$(systemctl is-active smbd)

---------------------------------------------------
Firewall
---------------------------------------------------
$(ufw status)

---------------------------------------------------
Running Services
---------------------------------------------------

$(running_services)

===================================================

EOF

}

dashboard() {

clear

echo "=============================================="
echo " LinuxOps Enterprise Server Alert Dashboard"
echo "=============================================="

echo ""

printf "%-25s : %s%%\n" "CPU Usage" "$(cpu_usage)"
printf "%-25s : %s%%\n" "Memory Usage" "$(memory_usage)"
printf "%-25s : %s%%\n" "Disk Usage" "$(disk_usage)"

echo ""

printf "%-25s : %s\n" "Nginx" "$(systemctl is-active nginx)"
printf "%-25s : %s\n" "Samba" "$(systemctl is-active smbd)"
printf "%-25s : %s\n" "Firewall" "$(systemctl is-active ufw)"

echo ""
echo "Logs : $LOG_FILE"
echo "Report : $REPORT_FILE"

echo ""

}

main() {

dashboard

check_cpu

check_memory

check_disk

check_nginx

check_samba

check_firewall

generate_report

echo ""
echo "=========================================="
echo " Health Check Completed Successfully"
echo "=========================================="
echo ""
echo "Log File"
echo "$LOG_FILE"
echo ""
echo "Report File"
echo "$REPORT_FILE"
echo ""

}

main