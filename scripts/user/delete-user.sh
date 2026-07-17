#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/user/delete-user.sh
# Description: Delete an existing Linux user safely.
# Author: Abhishek Shrivastava
# Version: 1.0
###############################################################################

LOG_DIR="../../logs"
LOG_FILE="$LOG_DIR/users.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# ---------- Colors ----------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

# ---------- Banner ----------
clear

echo -e "${CYAN}"
echo "==============================================================="
echo "              LinuxOps Enterprise Server"
echo "                  Delete Linux User"
echo "==============================================================="
echo -e "${NC}"

# ---------- Root Check ----------
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: Please run this script as root or with sudo.${NC}"
    exit 1
fi

# ---------- User Input ----------
read -rp "Enter username to delete: " USERNAME

if [[ -z "$USERNAME" ]]; then
    echo -e "${RED}Username cannot be empty.${NC}"
    exit 1
fi

# ---------- User Exists ----------
if ! id "$USERNAME" &>/dev/null; then
    echo -e "${RED}User '$USERNAME' does not exist.${NC}"

    echo "$(date '+%F %T') FAILED: User $USERNAME not found." >> "$LOG_FILE"

    exit 1
fi

echo
echo "User Information"
echo "----------------"

id "$USERNAME"

HOME_DIR=$(eval echo "~$USERNAME")

echo
echo "Home Directory : $HOME_DIR"

echo
echo "Delete Options"
echo "--------------"
echo "1. Delete user only"
echo "2. Delete user and home directory"
echo "3. Cancel"

echo

read -rp "Select option [1-3]: " OPTION

case $OPTION in

1)

    userdel "$USERNAME"

    if [[ $? -eq 0 ]]; then

        echo
        echo -e "${GREEN}User deleted successfully.${NC}"

        echo "$(date '+%F %T') User deleted: $USERNAME" >> "$LOG_FILE"

    else

        echo
        echo -e "${RED}Failed to delete user.${NC}"

        exit 1

    fi

;;

2)

    userdel -r "$USERNAME"

    if [[ $? -eq 0 ]]; then

        echo
        echo -e "${GREEN}User and home directory deleted successfully.${NC}"

        echo "$(date '+%F %T') User and home deleted: $USERNAME" >> "$LOG_FILE"

    else

        echo
        echo -e "${RED}Failed to delete user.${NC}"

        exit 1

    fi

;;

3)

    echo
    echo -e "${YELLOW}Operation cancelled.${NC}"

    exit 0

;;

*)

    echo
    echo -e "${RED}Invalid option.${NC}"

    exit 1

;;

esac

echo
echo "Current Users"
echo "-------------"

cut -d: -f1 /etc/passwd | sort

echo
echo -e "${BLUE}Operation completed successfully.${NC}"

exit 0