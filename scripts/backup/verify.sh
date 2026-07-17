#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File        : verify.sh
# Module      : Backup Verification
# Description : Verify backup archives and directories
# Author      : Abhishek Shrivastava
###############################################################################

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

BACKUP_ROOT="$PROJECT_DIR/backups"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"

mkdir -p "$BACKUP_ROOT"
mkdir -p "$LOG_DIR"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

header() {

clear

echo -e "${BLUE}"
echo "=============================================================="
echo "             LinuxOps Enterprise Server"
echo "                  Backup Verification"
echo "=============================================================="
echo -e "${RESET}"

}

pause() {

echo
read -rp "Press Enter to continue..."

}

verify_tar() {

echo
read -rp "Enter full path of backup (.tar.gz): " FILE

if [ ! -f "$FILE" ]; then

    echo -e "${RED}Backup file not found.${RESET}"
    log "Verification failed - File not found: $FILE"
    pause
    return

fi

echo
echo "Checking archive..."

if tar -tzf "$FILE" >/dev/null 2>&1; then

    echo -e "${GREEN}Archive is VALID.${RESET}"
    log "Verified archive: $FILE"

else

    echo -e "${RED}Archive is CORRUPTED.${RESET}"
    log "Corrupted archive: $FILE"

fi

pause

}

verify_directory() {

echo
read -rp "Enter backup directory: " DIR

if [ ! -d "$DIR" ]; then

    echo -e "${RED}Directory does not exist.${RESET}"
    log "Verification failed - Directory not found: $DIR"
    pause
    return

fi

echo
echo "Scanning backup..."

FILES=$(find "$DIR" -type f | wc -l)
SIZE=$(du -sh "$DIR" | awk '{print $1}')

echo "Directory : $DIR"
echo "Files     : $FILES"
echo "Size      : $SIZE"

if [ "$FILES" -eq 0 ]; then

    echo -e "${YELLOW}Backup directory is empty.${RESET}"
    log "Empty backup directory: $DIR"

else

    echo -e "${GREEN}Backup directory verified successfully.${RESET}"
    log "Verified directory: $DIR"

fi

pause

}

list_backups() {

echo
echo "Available Backup Files"
echo "----------------------"

find "$BACKUP_ROOT" \
-type f \
\( -name "*.tar" -o -name "*.tar.gz" \) \
-print

echo
pause

}

backup_summary() {

echo

TOTAL=$(find "$BACKUP_ROOT" -type f | wc -l)

SIZE=$(du -sh "$BACKUP_ROOT" | awk '{print $1}')

LATEST=$(find "$BACKUP_ROOT" -type f -printf "%T@ %p\n" 2>/dev/null \
| sort -nr \
| head -1 \
| cut -d' ' -f2-)

echo "Backup Location : $BACKUP_ROOT"
echo "Total Files     : $TOTAL"
echo "Disk Usage      : $SIZE"

if [ -n "$LATEST" ]; then

echo "Latest Backup   : $LATEST"

else

echo "Latest Backup   : None"

fi

echo

pause

}

verify_all_archives() {

echo

FOUND=0

while IFS= read -r FILE
do

FOUND=1

printf "%-60s" "$(basename "$FILE")"

if tar -tzf "$FILE" >/dev/null 2>&1; then

echo -e "${GREEN}OK${RESET}"

else

echo -e "${RED}FAILED${RESET}"

fi

done < <(find "$BACKUP_ROOT" -type f -name "*.tar.gz")

if [ "$FOUND" -eq 0 ]; then

echo "No backup archives found."

fi

echo
pause

}

while true
do

header

echo "1. Verify Backup Archive"
echo "2. Verify Backup Directory"
echo "3. List Backup Files"
echo "4. Backup Summary"
echo "5. Verify All Archives"
echo "0. Exit"

echo
read -rp "Select option: " OPTION

case "$OPTION" in

1)

verify_tar

;;

2)

verify_directory

;;

3)

list_backups

;;

4)

backup_summary

;;

5)

verify_all_archives

;;

0)

echo
echo "Goodbye."
exit 0

;;

*)

echo
echo -e "${RED}Invalid option.${RESET}"
sleep 1

;;

esac

done