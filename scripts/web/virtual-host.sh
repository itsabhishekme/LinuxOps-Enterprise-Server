#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File: scripts/web/virtual-host.sh
# Description:
# Create and configure an Nginx virtual host
# ============================================================

set -e

PROJECT_NAME="LinuxOps Enterprise Server"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

echo -e "${BLUE}"
echo "======================================================"
echo "      LinuxOps Enterprise Server"
echo "      Nginx Virtual Host Manager"
echo "======================================================"
echo -e "${NC}"

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Please run this script as root.${NC}"
    echo "Example:"
    echo "sudo bash virtual-host.sh"
    exit 1
fi

if ! command -v nginx >/dev/null 2>&1; then
    echo -e "${RED}Nginx is not installed.${NC}"
    exit 1
fi

read -p "Enter domain name (example.com): " DOMAIN

if [[ -z "$DOMAIN" ]]; then
    echo -e "${RED}Domain cannot be empty.${NC}"
    exit 1
fi

DEFAULT_ROOT="/var/www/$DOMAIN"

read -p "Website root [$DEFAULT_ROOT]: " ROOT

ROOT=${ROOT:-$DEFAULT_ROOT}

echo
echo "Configuration"
echo "----------------------------"
echo "Domain : $DOMAIN"
echo "Root   : $ROOT"
echo

read -p "Continue? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo
echo -e "${CYAN}Creating website directory...${NC}"

mkdir -p "$ROOT"

cat > "$ROOT/index.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>$DOMAIN</title>

<style>

body{

background:#111827;
color:white;
font-family:Arial,sans-serif;
display:flex;
justify-content:center;
align-items:center;
height:100vh;
flex-direction:column;

}

h1{

font-size:48px;
margin-bottom:20px;

}

p{

font-size:20px;

}

</style>

</head>

<body>

<h1>$DOMAIN</h1>

<p>Welcome to LinuxOps Enterprise Server</p>

<p>Nginx Virtual Host Successfully Configured.</p>

</body>

</html>
EOF

echo -e "${GREEN}Website root created.${NC}"

echo
echo -e "${CYAN}Creating Nginx configuration...${NC}"

cat > "/etc/nginx/sites-available/$DOMAIN" <<EOF
server {

    listen 80;

    listen [::]:80;

    server_name $DOMAIN www.$DOMAIN;

    root $ROOT;

    index index.html index.htm index.php;

    access_log /var/log/nginx/${DOMAIN}_access.log;

    error_log /var/log/nginx/${DOMAIN}_error.log;

    location / {

        try_files \$uri \$uri/ =404;

    }

}
EOF

ln -sf "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled/$DOMAIN"

if [ -f /etc/nginx/sites-enabled/default ]; then
    rm -f /etc/nginx/sites-enabled/default
fi

echo
echo -e "${CYAN}Testing Nginx configuration...${NC}"

if nginx -t; then

    echo -e "${GREEN}Configuration is valid.${NC}"

else

    echo -e "${RED}Configuration test failed.${NC}"
    exit 1

fi

echo
echo -e "${CYAN}Restarting Nginx...${NC}"

systemctl restart nginx

systemctl enable nginx >/dev/null 2>&1

echo
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Virtual Host Created Successfully${NC}"
echo -e "${GREEN}=========================================${NC}"

echo
echo "Domain            : $DOMAIN"
echo "Website Root      : $ROOT"
echo "Config File       : /etc/nginx/sites-available/$DOMAIN"
echo "Enabled Config    : /etc/nginx/sites-enabled/$DOMAIN"
echo "Access Log        : /var/log/nginx/${DOMAIN}_access.log"
echo "Error Log         : /var/log/nginx/${DOMAIN}_error.log"

IP=$(hostname -I | awk '{print $1}')

echo
echo "Server IP : $IP"

echo
echo "Open in browser"

echo "http://$DOMAIN"

echo "or"

echo "http://$IP"

echo
echo "Next Steps"
echo "----------"
echo "1. Point your domain DNS to this server IP."
echo "2. Install SSL using Certbot."
echo "3. Restart Nginx after any configuration changes."

echo
echo -e "${GREEN}Done.${NC}"