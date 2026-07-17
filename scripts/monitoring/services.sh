#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File: scripts/monitoring/services.sh
# Description: Monitor important Linux services
# Author: Abhishek Shrivastava
# ============================================================

LOG_DIR="../../logs"
REPORT_DIR="../../reports"

LOG_FILE="$LOG_DIR/monitor.log"
REPORT_FILE="$REPORT_DIR/services-report.txt"

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

SERVICES=(
    "ssh"
    "cron"
    "nginx"
    "smbd"
    "ufw"
)

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

line() {
    printf "%0.s=" {1..70}
    echo
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

status_color() {
    if [ "$1" = "active" ]; then
        echo -e "${GREEN}RUNNING${NC}"
    else
        echo -e "${RED}STOPPED${NC}"
    fi
}

check_service() {

    SERVICE_NAME=$1

    if systemctl list-unit-files | grep -q "^${SERVICE_NAME}.service"; then

        STATUS=$(systemctl is-active "$SERVICE_NAME" 2>/dev/null)

        if [ "$STATUS" = "active" ]; then
            printf "%-20s %b\n" "$SERVICE_NAME" "$(status_color active)"
            log_message "$SERVICE_NAME : RUNNING"
            echo "$SERVICE_NAME : RUNNING" >> "$REPORT_FILE"
        else
            printf "%-20s %b\n" "$SERVICE_NAME" "$(status_color inactive)"
            log_message "$SERVICE_NAME : STOPPED"
            echo "$SERVICE_NAME : STOPPED" >> "$REPORT_FILE"
        fi

    else
        printf "%-20s ${YELLOW}NOT INSTALLED${NC}\n" "$SERVICE_NAME"
        log_message "$SERVICE_NAME : NOT INSTALLED"
        echo "$SERVICE_NAME : NOT INSTALLED" >> "$REPORT_FILE"
    fi

}

show_uptime() {

    echo
    line
    echo -e "${CYAN}System Uptime${NC}"
    line

    uptime -p

}

show_failed_services() {

    echo
    line
    echo -e "${RED}Failed Services${NC}"
    line

    systemctl --failed --no-pager

}

show_enabled_services() {

    echo
    line
    echo -e "${BLUE}Enabled Services${NC}"
    line

    systemctl list-unit-files --type=service --state=enabled --no-pager

}

generate_report_header() {

    echo "==========================================" > "$REPORT_FILE"
    echo " LinuxOps Service Monitoring Report" >> "$REPORT_FILE"
    echo "==========================================" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Generated : $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

}

monitor_all_services() {

    clear

    generate_report_header

    line
    echo -e "${GREEN}LinuxOps Enterprise Server${NC}"
    echo "Service Monitoring"
    line

    for SERVICE in "${SERVICES[@]}"
    do
        check_service "$SERVICE"
    done

    show_uptime

    echo
    show_failed_services

    echo
    show_enabled_services

    echo
    line
    echo "Report saved:"
    echo "$REPORT_FILE"
    line

}

while true
do

    echo
    line
    echo "LinuxOps Service Monitor"
    line

    echo "1. Monitor Services"
    echo "2. Show Failed Services"
    echo "3. Show Enabled Services"
    echo "4. Show Uptime"
    echo "5. Exit"

    echo
    read -rp "Select Option: " OPTION

    case $OPTION in

        1)

            monitor_all_services
            ;;

        2)

            show_failed_services
            ;;

        3)

            show_enabled_services
            ;;

        4)

            show_uptime
            ;;

        5)

            echo
            echo "Goodbye..."
            exit 0
            ;;

        *)

            echo
            echo "Invalid Option."
            ;;

    esac

done