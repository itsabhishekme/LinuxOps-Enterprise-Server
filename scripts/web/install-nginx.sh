#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File        : scripts/web/install-nginx.sh
# Description : Install and Configure Nginx Web Server
# Author      : Abhishek Shrivastava
###############################################################################

set -e

PROJECT_NAME="LinuxOps Enterprise Server"
LOG_DIR="../../logs"
LOG_FILE="$LOG_DIR/server.log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

###############################################################################
# Create log directory
###############################################################################

mkdir -p "$LOG_DIR"

###############################################################################
# Logging Function
###############################################################################

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

###############################################################################
# Banner
###############################################################################

banner() {

clear

echo -e "${CYAN}"
echo "============================================================"
echo "          LinuxOps Enterprise Server"
echo "             NGINX INSTALLER"
echo "============================================================"
echo -e "${NC}"

}

###############################################################################
# Root Check
###############################################################################

check_root() {

if [ "$EUID" -ne 0 ]; then

    echo -e "${RED}Please run using sudo.${NC}"
    exit 1

fi

}

###############################################################################
# Internet Check
###############################################################################

check_network() {

echo -e "${BLUE}Checking Internet Connection...${NC}"

if ping -c 1 google.com >/dev/null 2>&1
then
    echo -e "${GREEN}Internet Connection Available${NC}"
    log "Internet Connection OK"
else
    echo -e "${RED}No Internet Connection${NC}"
    log "Internet Connection Failed"
    exit 1
fi

}

###############################################################################
# Update Packages
###############################################################################

update_packages() {

echo
echo -e "${BLUE}Updating Package Repository...${NC}"

apt update -y

echo -e "${GREEN}Repository Updated${NC}"

log "APT Updated"

}

###############################################################################
# Install Nginx
###############################################################################

install_nginx() {

echo
echo -e "${BLUE}Installing Nginx...${NC}"

apt install nginx -y

echo -e "${GREEN}Nginx Installed Successfully${NC}"

log "Nginx Installed"

}

###############################################################################
# Enable Service
###############################################################################

enable_service() {

echo
echo -e "${BLUE}Enabling Nginx Service...${NC}"

systemctl enable nginx

systemctl start nginx

echo -e "${GREEN}Nginx Started${NC}"

log "Nginx Started"

}

###############################################################################
# Configure Firewall
###############################################################################

configure_firewall() {

echo
echo -e "${BLUE}Configuring Firewall...${NC}"

if command -v ufw >/dev/null
then

    ufw allow 'Nginx Full'

    ufw reload

    echo -e "${GREEN}Firewall Updated${NC}"

    log "Firewall Configured"

else

    echo -e "${YELLOW}UFW Not Installed. Skipping.${NC}"

    log "UFW Missing"

fi

}

###############################################################################
# Backup Default Website
###############################################################################

backup_default_site() {

echo
echo -e "${BLUE}Backing Up Default Website...${NC}"

if [ -d /var/www/html ]; then

    cp -r /var/www/html /var/www/html_backup_$(date +%F_%H%M%S)

    echo -e "${GREEN}Backup Completed${NC}"

    log "Default Website Backed Up"

fi

}

###############################################################################
# Deploy Sample Website
###############################################################################

deploy_site() {

echo
echo -e "${BLUE}Deploying Website...${NC}"

mkdir -p /var/www/html

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>LinuxOps Enterprise Server</title>

<style>

body{

background:#0f172a;
color:white;
font-family:Arial;
display:flex;
justify-content:center;
align-items:center;
height:100vh;
text-align:center;

}

h1{

font-size:48px;

}

p{

font-size:20px;

}

</style>

</head>

<body>

<div>

<h1>LinuxOps Enterprise Server</h1>

<p>Nginx Installation Successful</p>

<p>Server is Running Successfully</p>

</div>

</body>

</html>
EOF

echo -e "${GREEN}Website Deployed${NC}"

log "Website Deployed"

}

###############################################################################
# Restart Service
###############################################################################

restart_nginx() {

echo
echo -e "${BLUE}Restarting Nginx...${NC}"

systemctl restart nginx

echo -e "${GREEN}Nginx Restarted${NC}"

log "Nginx Restarted"

}

###############################################################################
# Verify Installation
###############################################################################

verify() {

echo
echo -e "${BLUE}Checking Nginx Status...${NC}"

systemctl --no-pager status nginx

echo

nginx -v

echo

ss -tulpn | grep :80 || true

log "Verification Completed"

}

###############################################################################
# Display Server Information
###############################################################################

summary() {

IP=$(hostname -I | awk '{print $1}')

echo
echo -e "${GREEN}"
echo "======================================================="
echo "Installation Completed Successfully"
echo "======================================================="
echo
echo "Open Browser:"
echo
echo "http://$IP"
echo
echo "Local:"
echo
echo "http://localhost"
echo
echo "Document Root:"
echo "/var/www/html"
echo
echo "Log File:"
echo "$LOG_FILE"
echo
echo "======================================================="
echo -e "${NC}"

}

###############################################################################
# Main
###############################################################################

banner

check_root

check_network

update_packages

install_nginx

enable_service

configure_firewall

backup_default_site

deploy_site

restart_nginx

verify

summary

exit 0