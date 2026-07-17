#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/install.sh
# Description: Complete installation and setup script
# Author: Abhishek Shrivastava
# Version: 1.0.0
###############################################################################

set -e

PROJECT_NAME="LinuxOps Enterprise Server"
VERSION="1.0.0"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${CYAN}"
echo "=============================================================="
echo "             $PROJECT_NAME"
echo "=============================================================="
echo "Version : $VERSION"
echo "Project : $ROOT_DIR"
echo "=============================================================="
echo -e "${RESET}"

###############################################
# Root Check
###############################################

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Please run as root or using sudo.${RESET}"
    exit 1
fi

###############################################
# Update System
###############################################

update_system() {

echo -e "${BLUE}Updating package list...${RESET}"

apt update

echo -e "${GREEN}Package list updated.${RESET}"

}

###############################################
# Upgrade Packages
###############################################

upgrade_system() {

echo -e "${BLUE}Upgrading installed packages...${RESET}"

apt upgrade -y

echo -e "${GREEN}System upgraded.${RESET}"

}

###############################################
# Install Required Packages
###############################################

install_packages() {

echo -e "${BLUE}Installing required packages...${RESET}"

PACKAGES=(
bash
git
curl
wget
zip
unzip
tree
vim
nano
cron
rsync
tar
htop
net-tools
openssh-server
nginx
samba
ufw
nmap
software-properties-common
)

for package in "${PACKAGES[@]}"
do

    if dpkg -s "$package" >/dev/null 2>&1
    then
        echo -e "${GREEN}$package already installed.${RESET}"
    else
        echo -e "${YELLOW}Installing $package...${RESET}"
        apt install -y "$package"
    fi

done

echo -e "${GREEN}All required packages installed.${RESET}"

}

###############################################
# Enable Services
###############################################

enable_services() {

echo -e "${BLUE}Enabling services...${RESET}"

SERVICES=(
cron
ssh
nginx
smbd
)

for service in "${SERVICES[@]}"
do

systemctl enable "$service"

done

echo -e "${GREEN}Services enabled.${RESET}"

}

###############################################
# Start Services
###############################################

start_services() {

echo -e "${BLUE}Starting services...${RESET}"

SERVICES=(
cron
ssh
nginx
smbd
)

for service in "${SERVICES[@]}"
do

systemctl restart "$service"

done

echo -e "${GREEN}Services started.${RESET}"

}

###############################################
# Create Runtime Directories
###############################################

create_directories() {

echo -e "${BLUE}Creating runtime folders...${RESET}"

mkdir -p "$ROOT_DIR/logs"
mkdir -p "$ROOT_DIR/backups/daily"
mkdir -p "$ROOT_DIR/backups/weekly"
mkdir -p "$ROOT_DIR/backups/monthly"
mkdir -p "$ROOT_DIR/reports"
mkdir -p "$ROOT_DIR/shares/public"
mkdir -p "$ROOT_DIR/shares/private"

echo -e "${GREEN}Directories ready.${RESET}"

}

###############################################
# Set Permissions
###############################################

set_permissions() {

echo -e "${BLUE}Setting permissions...${RESET}"

find "$ROOT_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;

chmod -R 755 "$ROOT_DIR"

echo -e "${GREEN}Permissions updated.${RESET}"

}

###############################################
# Configure Firewall
###############################################

configure_firewall() {

echo -e "${BLUE}Configuring firewall...${RESET}"

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp

echo "y" | ufw enable

echo -e "${GREEN}Firewall configured.${RESET}"

}

###############################################
# Configure Nginx
###############################################

configure_nginx() {

echo -e "${BLUE}Configuring Nginx...${RESET}"

if [ -f "$ROOT_DIR/website/index.html" ]; then

cp "$ROOT_DIR/website/index.html" /var/www/html/index.html

fi

systemctl restart nginx

echo -e "${GREEN}Nginx configured.${RESET}"

}

###############################################
# Configure Samba
###############################################

configure_samba() {

echo -e "${BLUE}Configuring Samba...${RESET}"

mkdir -p /srv/linuxops-share

chmod 777 /srv/linuxops-share

if ! grep -q "LinuxOpsShare" /etc/samba/smb.conf
then

cat <<EOF >> /etc/samba/smb.conf

[LinuxOpsShare]
path = /srv/linuxops-share
browseable = yes
writable = yes
guest ok = yes
read only = no
create mask = 0775
directory mask = 0775

EOF

fi

systemctl restart smbd

echo -e "${GREEN}Samba configured.${RESET}"

}

###############################################
# Installation Summary
###############################################

summary() {

echo
echo -e "${GREEN}"
echo "===================================================="
echo "Installation Completed Successfully"
echo "===================================================="
echo
echo "Installed Components"
echo
echo "✔ Bash"
echo "✔ Git"
echo "✔ Curl"
echo "✔ Wget"
echo "✔ Tree"
echo "✔ Cron"
echo "✔ Rsync"
echo "✔ SSH"
echo "✔ Nginx"
echo "✔ Samba"
echo "✔ UFW"
echo "✔ Nmap"
echo
echo "Website:"
echo "http://localhost"
echo
echo "Project:"
echo "$ROOT_DIR"
echo
echo "Firewall:"
ufw status

echo
echo "Services:"
systemctl --type=service --state=running | grep -E "nginx|cron|ssh|smbd"

echo "===================================================="
echo -e "${RESET}"

}

###############################################
# Main
###############################################

main() {

update_system

upgrade_system

install_packages

enable_services

start_services

create_directories

set_permissions

configure_firewall

configure_nginx

configure_samba

summary

}

main