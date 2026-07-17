#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/samba/install.sh
# Description: Install and configure Samba File Server
# Author: Abhishek Shrivastava
###############################################################################

set -e

PROJECT_NAME="LinuxOps Enterprise Server"
VERSION="1.0.0"

SHARE_PUBLIC="/srv/samba/public"
SHARE_PRIVATE="/srv/samba/private"

SMB_CONFIG="/etc/samba/smb.conf"
BACKUP_CONFIG="/etc/samba/smb.conf.bak"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

print_line() {
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '='
}

header() {
    clear
    print_line
    echo -e "${CYAN}${PROJECT_NAME}${NC}"
    echo "Samba Installation & Configuration"
    echo "Version : ${VERSION}"
    print_line
}

check_root() {

    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run this script as root.${NC}"
        exit 1
    fi

}

install_packages() {

    echo
    echo -e "${BLUE}Updating packages...${NC}"

    apt update

    echo
    echo -e "${BLUE}Installing Samba...${NC}"

    apt install -y samba samba-common

}

backup_config() {

    if [ -f "$SMB_CONFIG" ]; then

        cp "$SMB_CONFIG" "$BACKUP_CONFIG"

        echo -e "${GREEN}Backup created:${NC} $BACKUP_CONFIG"

    fi

}

create_directories() {

    echo
    echo -e "${BLUE}Creating shared directories...${NC}"

    mkdir -p "$SHARE_PUBLIC"
    mkdir -p "$SHARE_PRIVATE"

    chmod 777 "$SHARE_PUBLIC"
    chmod 770 "$SHARE_PRIVATE"

    chown nobody:nogroup "$SHARE_PUBLIC"

}

configure_samba() {

cat > "$SMB_CONFIG" <<EOF
[global]
   workgroup = WORKGROUP
   server string = LinuxOps Enterprise Server
   security = user
   map to guest = Bad User
   dns proxy = no

[Public]
   path = $SHARE_PUBLIC
   browseable = yes
   writable = yes
   guest ok = yes
   read only = no
   force user = nobody

[Private]
   path = $SHARE_PRIVATE
   browseable = yes
   writable = yes
   guest ok = no
   read only = no
   valid users = @sambausers
EOF

echo -e "${GREEN}Samba configuration updated.${NC}"

}

create_group() {

    if getent group sambausers > /dev/null
    then

        echo "Group sambausers already exists."

    else

        groupadd sambausers

        echo "Group sambausers created."

    fi

}

start_service() {

    systemctl enable smbd
    systemctl enable nmbd

    systemctl restart smbd
    systemctl restart nmbd

}

verify() {

    echo
    echo -e "${BLUE}Testing configuration...${NC}"

    testparm -s

    echo
    echo -e "${GREEN}Service Status${NC}"

    systemctl --no-pager status smbd | head -12

}

firewall() {

    if command -v ufw >/dev/null 2>&1
    then

        ufw allow Samba

    fi

}

summary() {

print_line

echo -e "${GREEN}Installation Completed Successfully${NC}"

print_line

echo

echo "Public Share : $SHARE_PUBLIC"
echo "Private Share: $SHARE_PRIVATE"

echo
echo "Configuration File:"
echo "$SMB_CONFIG"

echo
echo "Useful Commands"

echo
echo "systemctl status smbd"
echo "systemctl restart smbd"
echo "testparm"
echo "smbclient -L localhost"

echo

}

main() {

    header

    check_root

    install_packages

    backup_config

    create_directories

    configure_samba

    create_group

    firewall

    start_service

    verify

    summary

}

main