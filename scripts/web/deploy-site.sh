#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File: scripts/web/deploy-site.sh
# Description:
# Deploy a static website to the Nginx web root.
# ============================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SOURCE_DIR="$PROJECT_ROOT/website"
NGINX_ROOT="/var/www/linuxops"
NGINX_CONF="/etc/nginx/sites-available/linuxops"
LOG_FILE="$PROJECT_ROOT/logs/server.log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"

log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

header() {
    clear
    echo -e "${BLUE}"
    echo "====================================================="
    echo "      LinuxOps Enterprise Server"
    echo "        Website Deployment"
    echo "====================================================="
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Please run this script with sudo.${NC}"
        exit 1
    fi
}

check_nginx() {
    if ! command -v nginx >/dev/null 2>&1; then
        echo -e "${RED}Nginx is not installed.${NC}"
        echo "Install it first:"
        echo "sudo apt install nginx -y"
        exit 1
    fi
}

create_directory() {

    echo -e "${YELLOW}Creating web root...${NC}"

    mkdir -p "$NGINX_ROOT"

    chown -R www-data:www-data "$NGINX_ROOT"

    chmod -R 755 "$NGINX_ROOT"

}

copy_files() {

    echo -e "${YELLOW}Copying website files...${NC}"

    cp -r "$SOURCE_DIR/"* "$NGINX_ROOT/"

}

create_nginx_config() {

cat > "$NGINX_CONF" <<EOF
server {

    listen 80;

    server_name _;

    root $NGINX_ROOT;

    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;

}
EOF

}

enable_site() {

    if [ ! -L /etc/nginx/sites-enabled/linuxops ]; then
        ln -s "$NGINX_CONF" /etc/nginx/sites-enabled/linuxops
    fi

    if [ -f /etc/nginx/sites-enabled/default ]; then
        rm -f /etc/nginx/sites-enabled/default
    fi

}

reload_nginx() {

    echo -e "${YELLOW}Testing Nginx configuration...${NC}"

    nginx -t

    echo -e "${YELLOW}Restarting Nginx...${NC}"

    systemctl restart nginx

    systemctl enable nginx

}

show_status() {

    echo

    echo -e "${GREEN}Website deployed successfully.${NC}"

    echo

    echo "Website Directory : $NGINX_ROOT"

    echo "Configuration     : $NGINX_CONF"

    echo

    IP=$(hostname -I | awk '{print $1}')

    echo "Access locally:"

    echo

    echo "http://localhost"

    echo

    if [[ -n "$IP" ]]; then
        echo "http://$IP"
    fi

    echo

}

main() {

    header

    check_root

    check_nginx

    create_directory

    copy_files

    create_nginx_config

    enable_site

    reload_nginx

    log "Website deployed successfully."

    show_status

}

main