#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/scanner/remote.sh
# Description:
# Scan a remote host using Nmap and save the results.
#
# Usage:
#   ./remote.sh
#
# Requirements:
#   - nmap installed
#   - Network connectivity
#   - Root privileges recommended for SYN scans
###############################################################################

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/reports"
LOG_DIR="$PROJECT_ROOT/logs"

REPORT_FILE="$REPORT_DIR/remote-scan-report.txt"
LOG_FILE="$LOG_DIR/server.log"

mkdir -p "$REPORT_DIR"
mkdir -p "$LOG_DIR"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

banner() {

clear

echo -e "${CYAN}"
echo "==============================================================="
echo "              LinuxOps Enterprise Server"
echo "                 Remote Port Scanner"
echo "==============================================================="
echo -e "${NC}"

}

log(){

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"

}

check_nmap(){

if ! command -v nmap >/dev/null 2>&1
then
    echo -e "${RED}Nmap is not installed.${NC}"
    echo
    echo "Install it using:"
    echo "sudo apt install nmap -y"
    exit 1
fi

}

validate_ip(){

local IP="$1"

if [[ "$IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
then
    return 0
fi

return 1

}

host_ping(){

local HOST="$1"

echo
echo "Checking host availability..."

if ping -c 2 "$HOST" >/dev/null 2>&1
then
    echo -e "${GREEN}Host is reachable.${NC}"
else
    echo -e "${YELLOW}Host did not respond to ping."
    echo "Continuing with scan...${NC}"
fi

}

scan_default(){

local HOST="$1"

echo
echo -e "${BLUE}Running Default Scan...${NC}"

nmap "$HOST" | tee "$REPORT_FILE"

}

scan_fast(){

local HOST="$1"

echo
echo -e "${BLUE}Running Fast Scan...${NC}"

nmap -T4 -F "$HOST" | tee "$REPORT_FILE"

}

scan_full(){

local HOST="$1"

echo
echo -e "${BLUE}Running Full Port Scan...${NC}"

nmap -p- "$HOST" | tee "$REPORT_FILE"

}

scan_service(){

local HOST="$1"

echo
echo -e "${BLUE}Running Service Detection...${NC}"

sudo nmap -sV "$HOST" | tee "$REPORT_FILE"

}

scan_os(){

local HOST="$1"

echo
echo -e "${BLUE}Running OS Detection...${NC}"

sudo nmap -O "$HOST" | tee "$REPORT_FILE"

}

scan_aggressive(){

local HOST="$1"

echo
echo -e "${BLUE}Running Aggressive Scan...${NC}"

sudo nmap -A "$HOST" | tee "$REPORT_FILE"

}

scan_custom_ports(){

local HOST="$1"

read -rp "Enter Ports (Example: 22,80,443): " PORTS

echo

sudo nmap -p "$PORTS" "$HOST" | tee "$REPORT_FILE"

}

menu(){

echo
echo "1. Default Scan"
echo "2. Fast Scan"
echo "3. Full Port Scan"
echo "4. Service Version Detection"
echo "5. Operating System Detection"
echo "6. Aggressive Scan"
echo "7. Custom Ports Scan"
echo "8. Exit"
echo

read -rp "Choose Option: " OPTION

case "$OPTION" in

1)
scan_default "$HOST"
;;

2)
scan_fast "$HOST"
;;

3)
scan_full "$HOST"
;;

4)
scan_service "$HOST"
;;

5)
scan_os "$HOST"
;;

6)
scan_aggressive "$HOST"
;;

7)
scan_custom_ports "$HOST"
;;

8)
exit 0
;;

*)
echo "Invalid Option"
exit 1
;;

esac

}

save_summary(){

echo
echo "--------------------------------------------------"
echo "Remote Scan Completed"
echo "--------------------------------------------------"
echo "Target : $HOST"
echo "Report : $REPORT_FILE"
echo "Finished : $(date)"
echo "--------------------------------------------------"

log "Remote scan completed for $HOST"

}

#############################

banner

check_nmap

echo

read -rp "Enter Remote IP Address or Hostname: " HOST

if [[ -z "$HOST" ]]
then
    echo -e "${RED}Host cannot be empty.${NC}"
    exit 1
fi

if validate_ip "$HOST"
then
    echo "IP Address detected."
else
    echo "Hostname detected."
fi

host_ping "$HOST"

menu

save_summary

echo
echo -e "${GREEN}Report saved successfully.${NC}"
echo