#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# Module      : User Management
# Script      : list-users.sh
# Description : Display Linux users with useful account information
# Author      : Abhishek Shrivastava
# Version     : 1.0.0
###############################################################################

LOG_DIR="../../logs"
LOG_FILE="$LOG_DIR/users.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

clear

echo "==============================================================="
echo "             LinuxOps Enterprise Server"
echo "==============================================================="
echo "                  List Linux Users"
echo "==============================================================="
echo

TOTAL_USERS=$(awk -F: 'END{print NR}' /etc/passwd)

echo "Total Users : $TOTAL_USERS"
echo

printf "%-20s %-8s %-8s %-25s %-30s\n" \
"USERNAME" "UID" "GID" "SHELL" "HOME"

echo "-------------------------------------------------------------------------------------------------------------"

while IFS=: read -r USER PASS UID GID DESC HOME SHELL
do
    printf "%-20s %-8s %-8s %-25s %-30s\n" \
    "$USER" \
    "$UID" \
    "$GID" \
    "$SHELL" \
    "$HOME"

done < /etc/passwd

echo
echo "==============================================================="
echo

echo "Normal Users (UID >=1000)"
echo

printf "%-20s %-8s %-30s\n" \
"USERNAME" "UID" "HOME"

echo "---------------------------------------------------------------"

awk -F: '$3>=1000 && $3<65534 {
printf "%-20s %-8s %-30s\n",$1,$3,$6
}' /etc/passwd

echo
echo "==============================================================="
echo

echo "Currently Logged In Users"
echo

who

echo
echo "==============================================================="
echo

echo "Users with Login Shell"

echo

grep "/bin/bash" /etc/passwd | cut -d: -f1

echo
echo "==============================================================="
echo

echo "Users with Home Directories"

echo

for user in $(awk -F: '{print $1}' /etc/passwd)
do
    HOME_DIR=$(grep "^$user:" /etc/passwd | cut -d: -f6)

    if [ -d "$HOME_DIR" ]; then
        echo "✓ $user --> $HOME_DIR"
    fi
done

echo
echo "==============================================================="
echo

echo "Last Login Information"

echo

lastlog

echo
echo "==============================================================="
echo

DATE=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$DATE] User list viewed." >> "$LOG_FILE"

echo "Log Saved : $LOG_FILE"

echo
echo "Done."