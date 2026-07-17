#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/monitoring/monitor.sh
# Description:
# Comprehensive Linux System Monitoring Script
###############################################################################

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

LOG_DIR="$PROJECT_ROOT/logs"
REPORT_DIR="$PROJECT_ROOT/reports"

LOG_FILE="$LOG_DIR/monitor.log"

CPU_REPORT="$REPORT_DIR/cpu-report.txt"
MEMORY_REPORT="$REPORT_DIR/memory-report.txt"
DISK_REPORT="$REPORT_DIR/disk-report.txt"

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

log(){

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"

}

line(){

    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '-'

}

header(){

    clear

    echo "=========================================================="
    echo "          LinuxOps Enterprise Server"
    echo "             System Monitoring"
    echo "=========================================================="
    echo

}

cpu_usage(){

    top -bn1 | awk '/Cpu\(s\)/ {print 100-$8}'

}

memory_usage(){

    free | awk '/Mem:/ {printf("%.2f"), $3/$2 *100}'

}

disk_usage(){

    df / | awk 'NR==2 {print $5}' | sed 's/%//'

}

network_info(){

    ip -4 addr show | awk '/inet / && $2 !~ /^127/ {print $2}'

}

uptime_info(){

    uptime -p

}

load_average(){

    uptime | awk -F'load average:' '{print $2}'

}

logged_users(){

    who | wc -l

}

running_processes(){

    ps -e --no-headers | wc -l

}

top_processes(){

    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head

}

service_status(){

    local service=$1

    if systemctl is-active --quiet "$service"
    then
        echo "Running"
    else
        echo "Stopped"
    fi

}

check_cpu(){

    local cpu=$(cpu_usage)

    printf "%.0f\n" "$cpu"

}

check_memory(){

    local mem=$(memory_usage)

    printf "%.0f\n" "$mem"

}

check_disk(){

    disk_usage

}

save_reports(){

cat > "$CPU_REPORT" <<EOF
LinuxOps Enterprise Server

CPU Report

Generated:
$(date)

CPU Usage:
$(cpu_usage) %

Load Average:
$(load_average)

Top Processes:

$(top_processes)

EOF

cat > "$MEMORY_REPORT" <<EOF
LinuxOps Enterprise Server

Memory Report

Generated:
$(date)

Memory Usage:
$(memory_usage) %

$(free -h)

EOF

cat > "$DISK_REPORT" <<EOF
LinuxOps Enterprise Server

Disk Report

Generated:
$(date)

$(df -h)

EOF

}

system_summary(){

CPU=$(check_cpu)
MEM=$(check_memory)
DISK=$(check_disk)

echo "Hostname              : $(hostname)"
echo "Operating System      : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
echo "Kernel                : $(uname -r)"
echo "Current User          : $(whoami)"
echo "Current Time          : $(date)"
echo "Uptime                : $(uptime_info)"
echo
echo "CPU Usage             : ${CPU}%"
echo "Memory Usage          : ${MEM}%"
echo "Disk Usage            : ${DISK}%"
echo
echo "Load Average          : $(load_average)"
echo "Running Processes     : $(running_processes)"
echo "Logged Users          : $(logged_users)"
echo
echo "Network Address(es)"
network_info
echo
echo "Service Status"
echo "Nginx                 : $(service_status nginx)"
echo "Samba                 : $(service_status smbd)"
echo "SSH                   : $(service_status ssh)"
echo "Cron                  : $(service_status cron)"
echo

}

alerts(){

CPU=$(check_cpu)
MEM=$(check_memory)
DISK=$(check_disk)

echo
line
echo "Alerts"
line

if [ "$CPU" -ge 80 ]
then
    echo "WARNING : CPU usage is above 80%"
else
    echo "CPU      : Normal"
fi

if [ "$MEM" -ge 80 ]
then
    echo "WARNING : Memory usage is above 80%"
else
    echo "Memory   : Normal"
fi

if [ "$DISK" -ge 90 ]
then
    echo "WARNING : Disk usage above 90%"
else
    echo "Disk     : Normal"
fi

if ! systemctl is-active --quiet nginx
then
    echo "WARNING : Nginx service stopped"
fi

if ! systemctl is-active --quiet smbd
then
    echo "WARNING : Samba service stopped"
fi

if ! systemctl is-active --quiet ssh
then
    echo "WARNING : SSH service stopped"
fi

echo

}

live_monitor(){

while true
do

header

system_summary

alerts

echo
line
echo "Refreshing every 5 seconds..."
line

sleep 5

done

}

generate_once(){

header

system_summary

alerts

save_reports

log "System monitoring completed."

echo
echo "Reports saved in:"
echo "$REPORT_DIR"
echo

}

menu(){

while true
do

header

echo "1. System Summary"
echo "2. Live Monitor"
echo "3. Generate Reports"
echo "4. Exit"
echo
read -rp "Select Option: " option

case $option in

1)

generate_once
read -rp "Press Enter to continue..."

;;

2)

live_monitor

;;

3)

save_reports
echo
echo "Reports Generated Successfully."
echo
read -rp "Press Enter to continue..."

;;

4)

exit 0

;;

*)

echo
echo "Invalid Option"
sleep 2

;;

esac

done

}

menu