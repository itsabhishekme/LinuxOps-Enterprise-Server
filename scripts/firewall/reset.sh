#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/firewall/reset.sh
# Description:
# Reset all UFW firewall rules and restore the default configuration.
###############################################################################

set -e

LOG_DIR="../../logs"
LOG_FILE="$LOG_DIR/firewall.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ This script must be run as root."
        echo "Run:"
        echo "sudo ./reset.sh"
        exit 1
    fi
}

confirm_reset() {
    echo "========================================"
    echo " LinuxOps Firewall Reset"
    echo "========================================"
    echo
    echo "WARNING!"
    echo "This will:"
    echo "  • Disable the firewall"
    echo "  • Delete ALL existing firewall rules"
    echo "  • Restore UFW to factory defaults"
    echo

    read -rp "Continue? (yes/no): " answer

    case "$answer" in
        yes|YES|y|Y)
            ;;
        *)
            echo "Operation cancelled."
            exit 0
            ;;
    esac
}

reset_firewall() {

    log "Starting firewall reset..."

    echo
    echo "Disabling UFW..."
    ufw --force disable

    echo
    echo "Resetting firewall..."
    ufw --force reset

    echo
    echo "Applying default security policy..."

    ufw default deny incoming
    ufw default allow outgoing

    echo
    echo "Allowing SSH (Port 22)..."
    ufw allow 22/tcp comment "SSH"

    echo
    echo "Enabling firewall..."
    ufw --force enable

    log "Firewall reset completed successfully."

    echo
    echo "Firewall successfully reset."
}

show_status() {

    echo
    echo "==============================="
    echo " Current Firewall Status"
    echo "==============================="
    echo

    ufw status verbose

    echo
}

main() {

    check_root

    confirm_reset

    reset_firewall

    show_status

    echo "Log File:"
    echo "$LOG_FILE"

}

main