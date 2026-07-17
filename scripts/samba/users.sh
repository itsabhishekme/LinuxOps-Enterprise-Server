#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/samba/users.sh
# Description:
# Manage Samba Users
###############################################################################

LOG_FILE="../../logs/server.log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"

mkdir -p ../../logs

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

pause() {
    echo
    read -rp "Press Enter to continue..."
}

create_user() {

    echo
    echo -e "${BLUE}========== Create Samba User ==========${NC}"

    read -rp "Linux Username: " USERNAME

    if ! id "$USERNAME" >/dev/null 2>&1; then
        echo -e "${RED}Linux user does not exist.${NC}"
        log "Failed: Samba user $USERNAME (Linux user missing)"
        return
    fi

    echo
    sudo smbpasswd -a "$USERNAME"

    if [ $? -eq 0 ]; then
        echo
        echo -e "${GREEN}Samba user created successfully.${NC}"
        log "Created Samba user $USERNAME"
    else
        echo
        echo -e "${RED}Failed to create Samba user.${NC}"
        log "Failed creating Samba user $USERNAME"
    fi
}

delete_user() {

    echo
    echo -e "${BLUE}========== Delete Samba User ==========${NC}"

    read -rp "Username: " USERNAME

    sudo smbpasswd -x "$USERNAME"

    if [ $? -eq 0 ]; then
        echo
        echo -e "${GREEN}User removed.${NC}"
        log "Deleted Samba user $USERNAME"
    else
        echo
        echo -e "${RED}Unable to delete user.${NC}"
        log "Failed deleting Samba user $USERNAME"
    fi
}

enable_user() {

    echo
    echo -e "${BLUE}========== Enable User ==========${NC}"

    read -rp "Username: " USERNAME

    sudo smbpasswd -e "$USERNAME"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}User enabled.${NC}"
        log "Enabled Samba user $USERNAME"
    else
        echo -e "${RED}Operation failed.${NC}"
    fi
}

disable_user() {

    echo
    echo -e "${BLUE}========== Disable User ==========${NC}"

    read -rp "Username: " USERNAME

    sudo smbpasswd -d "$USERNAME"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}User disabled.${NC}"
        log "Disabled Samba user $USERNAME"
    else
        echo -e "${RED}Operation failed.${NC}"
    fi
}

change_password() {

    echo
    echo -e "${BLUE}========== Change Password ==========${NC}"

    read -rp "Username: " USERNAME

    sudo smbpasswd "$USERNAME"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Password updated.${NC}"
        log "Password changed for Samba user $USERNAME"
    else
        echo -e "${RED}Password update failed.${NC}"
    fi
}

list_users() {

    echo
    echo -e "${BLUE}========== Samba Users ==========${NC}"
    echo

    sudo pdbedit -L

    log "Viewed Samba user list"
}

show_user_info() {

    echo
    echo -e "${BLUE}========== User Details ==========${NC}"

    read -rp "Username: " USERNAME

    echo

    sudo pdbedit -Lv "$USERNAME"

    log "Viewed details of Samba user $USERNAME"
}

restart_service() {

    echo
    echo -e "${BLUE}Restarting Samba Service...${NC}"

    sudo systemctl restart smbd

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Samba restarted successfully.${NC}"
        log "Restarted Samba service"
    else
        echo -e "${RED}Restart failed.${NC}"
    fi
}

status_service() {

    echo
    echo -e "${BLUE}========== Samba Status ==========${NC}"
    echo

    systemctl status smbd --no-pager

    log "Viewed Samba service status"
}

menu() {

while true
do

clear

echo "=================================================="
echo "        LinuxOps Enterprise Server"
echo "            Samba User Manager"
echo "=================================================="
echo
echo "1. Create Samba User"
echo "2. Delete Samba User"
echo "3. Enable User"
echo "4. Disable User"
echo "5. Change Password"
echo "6. List Users"
echo "7. Show User Details"
echo "8. Restart Samba Service"
echo "9. Service Status"
echo "0. Exit"
echo
read -rp "Choose an option: " OPTION

case $OPTION in

1)
create_user
pause
;;

2)
delete_user
pause
;;

3)
enable_user
pause
;;

4)
disable_user
pause
;;

5)
change_password
pause
;;

6)
list_users
pause
;;

7)
show_user_info
pause
;;

8)
restart_service
pause
;;

9)
status_service
pause
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