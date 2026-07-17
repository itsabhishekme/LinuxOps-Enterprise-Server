#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File        : create-user.sh
# Description : Create a new Linux user with optional group assignment
# Author      : Abhishek Shrivastava
# Version     : 1.0
###############################################################################

LOG_FILE="../../logs/users.log"

# ----------------------------- Colors ---------------------------------------

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

# ---------------------------- Root Check ------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Please run this script as root or with sudo.${NC}"
    exit 1
fi

# ---------------------------- Log Function ----------------------------------

log_action() {
    mkdir -p ../../logs

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# --------------------------- Header -----------------------------------------

clear

echo -e "${CYAN}"
echo "========================================================"
echo "          LinuxOps Enterprise Server"
echo "              Create Linux User"
echo "========================================================"
echo -e "${NC}"

# -------------------------- Username ----------------------------------------

read -rp "Enter Username : " USERNAME

if [[ -z "$USERNAME" ]]; then
    echo -e "${RED}Username cannot be empty.${NC}"
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo -e "${RED}User already exists.${NC}"
    exit 1
fi

# -------------------------- Full Name ---------------------------------------

read -rp "Enter Full Name (Optional): " FULLNAME

# --------------------------- Password ---------------------------------------

while true
do

read -rsp "Enter Password : " PASSWORD
echo

read -rsp "Confirm Password : " CONFIRM
echo

if [[ "$PASSWORD" == "$CONFIRM" ]]; then
    break
fi

echo -e "${RED}Passwords do not match. Try again.${NC}"

done

# ---------------------------- Shell -----------------------------------------

echo
echo "Available Shells"

echo "1) /bin/bash"
echo "2) /bin/sh"
echo "3) /bin/zsh"

read -rp "Choose Shell [1-3] (Default Bash): " SHELL_CHOICE

case $SHELL_CHOICE in

2)
USER_SHELL="/bin/sh"
;;

3)
USER_SHELL="/bin/zsh"
;;

*)
USER_SHELL="/bin/bash"
;;

esac

# ---------------------------- Group -----------------------------------------

echo

read -rp "Primary Group (Leave blank for default): " GROUPNAME

# ----------------------------- Home -----------------------------------------

echo

read -rp "Create Home Directory? (Y/N): " HOME

HOME=$(echo "$HOME" | tr '[:lower:]' '[:upper:]')

# ----------------------------- Build Command --------------------------------

CMD="useradd"

if [[ "$HOME" == "Y" || "$HOME" == "YES" || -z "$HOME" ]]; then
    CMD+=" -m"
fi

CMD+=" -s $USER_SHELL"

if [[ -n "$FULLNAME" ]]; then
    CMD+=" -c \"$FULLNAME\""
fi

if [[ -n "$GROUPNAME" ]]; then

    if ! getent group "$GROUPNAME" >/dev/null
    then
        echo
        echo -e "${YELLOW}Group does not exist."

        read -rp "Create Group? (Y/N): " CREATE_GROUP

        CREATE_GROUP=$(echo "$CREATE_GROUP" | tr '[:lower:]' '[:upper:]')

        if [[ "$CREATE_GROUP" == "Y" || "$CREATE_GROUP" == "YES" ]]
        then

            groupadd "$GROUPNAME"

            echo -e "${GREEN}Group Created.${NC}"

            log_action "Created group : $GROUPNAME"

        else

            echo -e "${RED}Operation Cancelled.${NC}"
            exit 1

        fi

    fi

    CMD+=" -g $GROUPNAME"

fi

CMD+=" $USERNAME"

eval "$CMD"

if [[ $? -ne 0 ]]
then
    echo
    echo -e "${RED}Failed to create user.${NC}"
    exit 1
fi

echo "$USERNAME:$PASSWORD" | chpasswd

# --------------------------- Expiry -----------------------------------------

echo

read -rp "Force password change on first login? (Y/N): " EXPIRE

EXPIRE=$(echo "$EXPIRE" | tr '[:lower:]' '[:upper:]')

if [[ "$EXPIRE" == "Y" || "$EXPIRE" == "YES" ]]
then

    chage -d 0 "$USERNAME"

fi

# -------------------------- User Information --------------------------------

echo
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}User Successfully Created${NC}"
echo -e "${GREEN}=============================================${NC}"

echo

echo "Username        : $USERNAME"
echo "Full Name       : $FULLNAME"
echo "Shell           : $USER_SHELL"

if [[ -n "$GROUPNAME" ]]
then
echo "Primary Group   : $GROUPNAME"
else
echo "Primary Group   : Default"
fi

echo "Home Directory  : /home/$USERNAME"

echo

id "$USERNAME"

# -------------------------- Log ---------------------------------------------

log_action "Created User : $USERNAME"

# -------------------------- Permission --------------------------------------

chmod 700 "/home/$USERNAME" 2>/dev/null

# --------------------------- Finish -----------------------------------------

echo

echo -e "${GREEN}Operation Completed Successfully.${NC}"

echo

read -rp "Press ENTER to continue..."