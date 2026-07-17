#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/firewall/install.sh
# Description:
# Installs and configures UFW Firewall for LinuxOps Enterprise Server
#
# Author: Abhishek Shrivastava
###############################################################################

set -e

PROJECT_NAME="LinuxOps Enterprise Server"
LOG_DIR="../../logs"
LOG_FILE="$LOG_DIR/firewall.log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

header() {
    clear
    echo -e "${CYAN}"
    echo "==============================================================="
    echo "           LinuxOps Enterprise Server"
    echo "               Firewall Installer"
    echo "==============================================================="
    echo -e "${NC}"
}

require_root() {

    if [[ "$EUID" -ne 0 ]]; then

        echo -e "${RED}Please run this script using sudo.${NC}"
        exit 1

    fi

}

install_firewall() {

    echo -e "${BLUE}Updating package list...${NC}"

    apt update

    echo -e "${BLUE}Installing UFW...${NC}"

    apt install -y ufw

    log "UFW installed."

}

configure_defaults() {

    echo -e "${BLUE}Applying default firewall policies...${NC}"

    ufw --force reset

    ufw default deny incoming

    ufw default allow outgoing

    log "Default firewall policy configured."

}

allow_ssh() {

    echo -e "${BLUE}Allowing SSH (22)...${NC}"

    ufw allow 22/tcp

    log "SSH allowed."

}

allow_http() {

    echo -e "${BLUE}Allowing HTTP (80)...${NC}"

    ufw allow 80/tcp

    log "HTTP allowed."

}

allow_https() {

    echo -e "${BLUE}Allowing HTTPS (443)...${NC}"

    ufw allow 443/tcp

    log "HTTPS allowed."

}

allow_samba() {

    echo -e "${BLUE}Allowing Samba...${NC}"

    ufw allow Samba

    log "Samba allowed."

}

enable_firewall() {

    echo -e "${BLUE}Enabling firewall...${NC}"

    ufw --force enable

    log "Firewall enabled."

}

status() {

    echo
    echo -e "${GREEN}Current Firewall Status${NC}"
    echo

    ufw status verbose

    log "Firewall status displayed."

}

save_rules() {

    mkdir -p ../../configs/firewall

    ufw status numbered > ../../configs/firewall/firewall.rules

    log "Firewall rules exported."

}

finish() {

    echo
    echo -e "${GREEN}"
    echo "=============================================="
    echo "Firewall Installation Completed Successfully"
    echo "=============================================="
    echo -e "${NC}"

    echo

    echo "Installed Components"

    echo "-------------------------------"

    echo "✓ UFW Installed"

    echo "✓ Incoming Traffic Denied"

    echo "✓ Outgoing Traffic Allowed"

    echo "✓ SSH Enabled"

    echo "✓ HTTP Enabled"

    echo "✓ HTTPS Enabled"

    echo "✓ Samba Enabled"

    echo "✓ Firewall Active"

    echo

    log "Firewall installation completed."

}

main() {

    header

    require_root

    install_firewall

    configure_defaults

    allow_ssh

    allow_http

    allow_https

    allow_samba

    enable_firewall

    save_rules

    status

    finish

}

main