#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File: scripts/firewall/block-port.sh
# Description:
# Block TCP/UDP ports using UFW Firewall
# ============================================================

LOG_FILE="../../logs/firewall.log"

#--------------------------------------------------------------
# Check Root Permission
#--------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run as root."
    echo "Example:"
    echo "sudo ./block-port.sh"
    exit 1
fi

#--------------------------------------------------------------
# Ensure UFW is Installed
#--------------------------------------------------------------

if ! command -v ufw &>/dev/null; then
    echo "❌ UFW Firewall is not installed."
    echo "Install using:"
    echo "sudo apt install ufw -y"
    exit 1
fi

#--------------------------------------------------------------
# Enable UFW if Disabled
#--------------------------------------------------------------

STATUS=$(ufw status | head -n 1)

if [[ "$STATUS" == *inactive* ]]; then
    echo "UFW is inactive."
    read -p "Enable UFW now? (y/n): " ENABLE

    if [[ "$ENABLE" =~ ^[Yy]$ ]]; then
        ufw --force enable
    else
        echo "Firewall must be enabled first."
        exit 1
    fi
fi

#--------------------------------------------------------------
# Function: Validate Port
#--------------------------------------------------------------

validate_port() {

    local PORT=$1

    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if (( PORT < 1 || PORT > 65535 )); then
        return 1
    fi

    return 0
}

#--------------------------------------------------------------
# Function: Block Port
#--------------------------------------------------------------

block_port() {

    local PORT=$1
    local PROTOCOL=$2

    echo
    echo "Blocking Port $PORT/$PROTOCOL ..."
    echo

    ufw deny "$PORT/$PROTOCOL"

    if [[ $? -eq 0 ]]; then

        echo "========================================="
        echo "Port Blocked Successfully"
        echo "========================================="
        echo "Port      : $PORT"
        echo "Protocol  : $PROTOCOL"
        echo "Date      : $(date)"
        echo

        echo "$(date '+%F %T') | BLOCK | $PORT/$PROTOCOL" >> "$LOG_FILE"

    else

        echo
        echo "Failed to block port."
        echo

    fi

}

#--------------------------------------------------------------
# Menu
#--------------------------------------------------------------

while true
do

clear

echo "======================================"
echo " LinuxOps Firewall - Block Port"
echo "======================================"
echo
echo "1. Block TCP Port"
echo "2. Block UDP Port"
echo "3. Block Both TCP & UDP"
echo "4. Exit"
echo
read -p "Select Option: " OPTION

case $OPTION in

1)

    read -p "Enter TCP Port: " PORT

    if validate_port "$PORT"; then
        block_port "$PORT" tcp
    else
        echo "Invalid Port."
    fi

    ;;

2)

    read -p "Enter UDP Port: " PORT

    if validate_port "$PORT"; then
        block_port "$PORT" udp
    else
        echo "Invalid Port."
    fi

    ;;

3)

    read -p "Enter Port: " PORT

    if validate_port "$PORT"; then

        block_port "$PORT" tcp
        block_port "$PORT" udp

    else

        echo "Invalid Port."

    fi

    ;;

4)

    echo
    echo "Goodbye."
    exit 0
    ;;

*)

    echo
    echo "Invalid Option."
    ;;

esac

echo
read -p "Press Enter to continue..."

done