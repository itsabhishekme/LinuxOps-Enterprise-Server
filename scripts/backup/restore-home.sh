#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File        : restore-home.sh
# Description : Restore Home Directory Backup
# Author      : Abhishek Shrivastava
# Version     : 1.0
# ============================================================

BACKUP_DIR="../../backups"
LOG_FILE="../../logs/backup.log"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

clear

echo -e "${CYAN}"
echo "======================================================"
echo "        LinuxOps Enterprise Server"
echo "        Home Backup Restore Utility"
echo "======================================================"
echo -e "${NC}"

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root.${NC}"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
mkdir -p ../../logs

echo

echo -e "${BLUE}Available Backup Categories${NC}"
echo "---------------------------------------"
echo "1. Daily"
echo "2. Weekly"
echo "3. Monthly"
echo "0. Exit"
echo

read -p "Select backup category: " category

case $category in
1)
    RESTORE_DIR="$BACKUP_DIR/daily"
    ;;
2)
    RESTORE_DIR="$BACKUP_DIR/weekly"
    ;;
3)
    RESTORE_DIR="$BACKUP_DIR/monthly"
    ;;
0)
    exit 0
    ;;
*)
    echo -e "${RED}Invalid option.${NC}"
    exit 1
    ;;
esac

echo

if [ ! -d "$RESTORE_DIR" ]; then
    echo -e "${RED}Backup directory not found.${NC}"
    exit 1
fi

BACKUP_FILES=$(find "$RESTORE_DIR" -type f -name "*.tar.gz")

if [ -z "$BACKUP_FILES" ]; then
    echo -e "${RED}No backup archives found.${NC}"
    exit 1
fi

echo -e "${BLUE}Available Backups${NC}"
echo "---------------------------------------"

select BACKUP in $BACKUP_FILES
do
    if [ -n "$BACKUP" ]; then
        break
    fi
    echo "Invalid selection."
done

echo

echo "Selected Backup:"
echo "$BACKUP"

echo

read -p "Enter destination directory [/]: " DEST

if [ -z "$DEST" ]; then
    DEST="/"
fi

if [ ! -d "$DEST" ]; then
    echo -e "${RED}Destination directory does not exist.${NC}"
    exit 1
fi

echo

echo -e "${YELLOW}Restore Summary${NC}"
echo "---------------------------------------"
echo "Backup File : $BACKUP"
echo "Destination : $DEST"
echo

read -p "Continue? (y/n): " CONFIRM

case $CONFIRM in
y|Y)
    ;;
*)
    echo "Restore cancelled."
    exit 0
    ;;
esac

echo

echo -e "${BLUE}Restoring backup...${NC}"

tar -xzf "$BACKUP" -C "$DEST"

STATUS=$?

if [ $STATUS -eq 0 ]; then

    echo

    echo -e "${GREEN}Restore completed successfully.${NC}"

    echo "$(date '+%Y-%m-%d %H:%M:%S') | RESTORE SUCCESS | $BACKUP -> $DEST" >> "$LOG_FILE"

else

    echo

    echo -e "${RED}Restore failed.${NC}"

    echo "$(date '+%Y-%m-%d %H:%M:%S') | RESTORE FAILED | $BACKUP" >> "$LOG_FILE"

    exit 1

fi

echo

echo "---------------------------------------"
echo "Backup Information"
echo "---------------------------------------"

echo "Archive : $(basename "$BACKUP")"

echo "Size    : $(du -sh "$BACKUP" | awk '{print $1}')"

echo "Created : $(stat -c %y "$BACKUP")"

echo

echo "Files inside archive"

echo "---------------------------------------"

tar -tzf "$BACKUP"

echo

echo -e "${GREEN}Operation Finished.${NC}"

echo
echo "Log File:"
echo "$LOG_FILE"
echo
exit 0