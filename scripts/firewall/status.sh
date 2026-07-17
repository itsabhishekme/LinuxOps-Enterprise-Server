#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/firewall/status.sh
# Description: Display Firewall (UFW) Status and Security Information
# Author: Abhishek Shrivastava
###############################################################################

set -e

LOG_DIR="../../logs"
LOG_FILE="$LOG_DIR/firewall.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

line() {
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '='
}

header() {
    clear
    line
    echo -e "${CYAN}LinuxOps Enterprise Server${NC}"
    echo -e "${BLUE}Firewall Status Dashboard${NC}"
    line
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Please run this script with sudo.${NC}"
        exit 1
    fi
}

check_ufw() {
    if ! command -v ufw &>/dev/null; then
        echo -e "${RED}UFW is not installed.${NC}"
        exit 1
    fi
}

firewall_status() {

    echo
    echo -e "${YELLOW}Firewall Status${NC}"
    line

    STATUS=$(ufw status | head -n1)

    echo "$STATUS"

    log "Viewed firewall status."

}

firewall_rules() {

    echo
    echo -e "${YELLOW}Configured Rules${NC}"
    line

    ufw status numbered

}

default_policy() {

    echo
    echo -e "${YELLOW}Default Policies${NC}"
    line

    ufw status verbose | grep "Default"

}

open_ports() {

    echo
    echo -e "${YELLOW}Listening Ports${NC}"
    line

    if command -v ss &>/dev/null; then

        ss -tuln

    else

        netstat -tuln

    fi

}

running_services() {

    echo
    echo -e "${YELLOW}Common Services${NC}"
    line

    SERVICES=("ssh" "nginx" "apache2" "smbd" "vsftpd")

    for SERVICE in "${SERVICES[@]}"
    do

        if systemctl list-unit-files | grep -q "^${SERVICE}.service"; then

            STATUS=$(systemctl is-active "$SERVICE")

            if [[ "$STATUS" == "active" ]]; then

                echo -e "${GREEN}$SERVICE : Running${NC}"

            else

                echo -e "${RED}$SERVICE : $STATUS${NC}"

            fi

        fi

    done

}

system_info() {

    echo
    echo -e "${YELLOW}System Information${NC}"
    line

    echo "Hostname : $(hostname)"
    echo "User     : $(whoami)"
    echo "Kernel   : $(uname -r)"
    echo "Uptime   : $(uptime -p)"
    echo "IP Addr  : $(hostname -I)"

}

security_summary() {

    echo
    echo -e "${YELLOW}Security Summary${NC}"
    line

    if ufw status | grep -q "Status: active"; then

        echo -e "${GREEN}Firewall Protection : ENABLED${NC}"

    else

        echo -e "${RED}Firewall Protection : DISABLED${NC}"

    fi

    SSH=$(ufw status | grep "22" || true)

    if [[ -n "$SSH" ]]; then

        echo -e "${GREEN}SSH Port Allowed${NC}"

    else

        echo -e "${YELLOW}SSH Rule Not Found${NC}"

    fi

    HTTP=$(ufw status | grep "80" || true)

    if [[ -n "$HTTP" ]]; then

        echo -e "${GREEN}HTTP Allowed${NC}"

    else

        echo -e "${YELLOW}HTTP Not Allowed${NC}"

    fi

    HTTPS=$(ufw status | grep "443" || true)

    if [[ -n "$HTTPS" ]]; then

        echo -e "${GREEN}HTTPS Allowed${NC}"

    else

        echo -e "${YELLOW}HTTPS Not Allowed${NC}"

    fi

}

save_report() {

    REPORT="../../reports/security-report.txt"

    mkdir -p ../../reports

    {

        echo "========================================"
        echo " LinuxOps Firewall Security Report"
        echo "========================================"
        echo
        date
        echo

        echo "Firewall Status"
        ufw status
        echo

        echo "Firewall Rules"
        ufw status numbered
        echo

        echo "Listening Ports"
        ss -tuln

    } > "$REPORT"

    echo
    echo -e "${GREEN}Security report saved to:${NC}"
    echo "$REPORT"

    log "Generated firewall report."

}

footer() {

    line
    echo -e "${GREEN}Firewall status check completed successfully.${NC}"
    line

}

main() {

    check_root

    check_ufw

    header

    system_info

    firewall_status

    firewall_rules

    default_policy

    open_ports

    running_services

    security_summary

    save_report

    footer

}

main