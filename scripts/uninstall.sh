#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File        : uninstall.sh
# Description : Uninstall LinuxOps Enterprise Server Components
# Author      : Abhishek Shrivastava
# Version     : 1.0
###############################################################################

set -e

PROJECT_NAME="LinuxOps Enterprise Server"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

line() {
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

header() {
    clear
    line
    echo -e "${GREEN}${PROJECT_NAME} - Uninstaller${NC}"
    line
}

pause() {
    echo
    read -rp "Press Enter to continue..."
}

remove_nginx() {

    echo -e "${YELLOW}Stopping Nginx...${NC}"

    sudo systemctl stop nginx 2>/dev/null || true
    sudo systemctl disable nginx 2>/dev/null || true

    echo -e "${YELLOW}Removing Nginx...${NC}"

    sudo apt remove --purge -y nginx nginx-common 2>/dev/null || true
    sudo apt autoremove -y

    echo -e "${GREEN}Nginx removed.${NC}"
}

remove_samba() {

    echo -e "${YELLOW}Stopping Samba...${NC}"

    sudo systemctl stop smbd 2>/dev/null || true
    sudo systemctl disable smbd 2>/dev/null || true

    echo -e "${YELLOW}Removing Samba...${NC}"

    sudo apt remove --purge -y samba samba-common 2>/dev/null || true
    sudo apt autoremove -y

    echo -e "${GREEN}Samba removed.${NC}"
}

remove_firewall_rules() {

    echo -e "${YELLOW}Resetting UFW...${NC}"

    sudo ufw --force reset 2>/dev/null || true

    echo -e "${GREEN}Firewall reset completed.${NC}"
}

remove_cron() {

    echo -e "${YELLOW}Removing Cron Jobs...${NC}"

    crontab -r 2>/dev/null || true

    echo -e "${GREEN}Cron jobs removed.${NC}"
}

clean_logs() {

    echo -e "${YELLOW}Cleaning Logs...${NC}"

    rm -f logs/*.log 2>/dev/null || true

    echo -e "${GREEN}Logs removed.${NC}"
}

clean_reports() {

    echo -e "${YELLOW}Cleaning Reports...${NC}"

    rm -f reports/*.txt 2>/dev/null || true

    echo -e "${GREEN}Reports removed.${NC}"
}

clean_backups() {

    echo -e "${YELLOW}Cleaning Backup Files...${NC}"

    rm -rf backups/daily/*
    rm -rf backups/weekly/*
    rm -rf backups/monthly/*

    echo -e "${GREEN}Backups removed.${NC}"
}

clean_shares() {

    echo -e "${YELLOW}Cleaning Shared Folders...${NC}"

    rm -rf shares/public/*
    rm -rf shares/private/*

    echo -e "${GREEN}Shared folders cleaned.${NC}"
}

delete_project() {

    echo
    read -rp "Delete the entire project directory? (y/N): " answer

    case "$answer" in
        y|Y)

            cd ..

            PROJECT_DIR="LinuxOps-Enterprise-Server"

            if [ -d "$PROJECT_DIR" ]; then

                rm -rf "$PROJECT_DIR"

                echo -e "${GREEN}Project directory deleted.${NC}"

            else

                echo -e "${RED}Project directory not found.${NC}"

            fi

            ;;

        *)

            echo "Project directory preserved."

            ;;

    esac
}

full_uninstall() {

    remove_nginx

    remove_samba

    remove_firewall_rules

    remove_cron

    clean_logs

    clean_reports

    clean_backups

    clean_shares
}

menu() {

while true

do

header

echo "1. Remove Nginx"
echo "2. Remove Samba"
echo "3. Reset Firewall"
echo "4. Remove Cron Jobs"
echo "5. Delete Logs"
echo "6. Delete Reports"
echo "7. Delete Backups"
echo "8. Clean Shared Folders"
echo "9. Full Uninstall"
echo "10. Delete Project Folder"
echo "0. Exit"

echo

read -rp "Choose an option: " choice

case "$choice" in

1)

remove_nginx
pause
;;

2)

remove_samba
pause
;;

3)

remove_firewall_rules
pause
;;

4)

remove_cron
pause
;;

5)

clean_logs
pause
;;

6)

clean_reports
pause
;;

7)

clean_backups
pause
;;

8)

clean_shares
pause
;;

9)

full_uninstall
pause
;;

10)

delete_project
exit
;;

0)

echo
echo "Goodbye."
exit 0
;;

*)

echo
echo -e "${RED}Invalid option.${NC}"
pause
;;

esac

done

}

menu