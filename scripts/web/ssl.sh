#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File: scripts/web/ssl.sh
# Description:
# Configure HTTPS using Let's Encrypt (Certbot) for Nginx
# ============================================================

set -e

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"

print_header() {
    clear
    echo -e "${BLUE}"
    echo "=========================================================="
    echo "          LinuxOps Enterprise Server"
    echo "            SSL Configuration Utility"
    echo "=========================================================="
    echo -e "${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

check_root() {

    if [ "$EUID" -ne 0 ]; then
        error "Run this script as root."
        echo
        echo "Example:"
        echo "sudo ./ssl.sh"
        exit 1
    fi

}

check_nginx() {

    if ! command -v nginx >/dev/null 2>&1; then
        error "Nginx is not installed."
        exit 1
    fi

}

install_certbot() {

    warning "Installing Certbot..."

    apt update

    apt install certbot python3-certbot-nginx -y

    success "Certbot Installed."

}

request_ssl() {

    echo
    read -rp "Enter your domain (example.com): " DOMAIN

    echo
    read -rp "Enter your Email Address: " EMAIL

    if [ -z "$DOMAIN" ]; then
        error "Domain cannot be empty."
        exit 1
    fi

    certbot \
    --nginx \
    -d "$DOMAIN" \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    --redirect

    success "SSL certificate installed successfully."

}

verify_certificate() {

    echo
    warning "Checking Certificate..."

    certbot certificates

}

renew_certificate() {

    echo
    warning "Running Renewal Test..."

    certbot renew --dry-run

}

certificate_information() {

    echo
    echo "Certificate Location"

    echo
    echo "/etc/letsencrypt/live/"
    echo

    ls /etc/letsencrypt/live/ 2>/dev/null || true

}

auto_renew() {

    echo
    warning "Configuring Automatic Renewal..."

    if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then

        (
            crontab -l 2>/dev/null

            echo "0 3 * * * certbot renew --quiet"

        ) | crontab -

    fi

    success "Automatic renewal enabled."

}

remove_certificate() {

    echo

    read -rp "Enter Domain to Remove SSL: " DOMAIN

    certbot delete --cert-name "$DOMAIN"

    success "Certificate removed."

}

status() {

    echo
    echo "=============================================="
    echo "SSL STATUS"
    echo "=============================================="

    certbot certificates

}

menu() {

while true

do

echo
echo "============== SSL MENU =============="

echo "1. Install Certbot"

echo "2. Generate SSL Certificate"

echo "3. Verify Certificate"

echo "4. Test Auto Renewal"

echo "5. Enable Auto Renewal"

echo "6. Certificate Information"

echo "7. Remove SSL"

echo "8. SSL Status"

echo "9. Exit"

echo

read -rp "Choose Option: " OPTION

case $OPTION in

1)

install_certbot

;;

2)

request_ssl

;;

3)

verify_certificate

;;

4)

renew_certificate

;;

5)

auto_renew

;;

6)

certificate_information

;;

7)

remove_certificate

;;

8)

status

;;

9)

echo

success "Goodbye."

exit 0

;;

*)

error "Invalid Option"

;;

esac

done

}

main() {

print_header

check_root

check_nginx

menu

}

main