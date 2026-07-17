#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# Module      : Backup Manager
# Script      : backup-home.sh
# Description : Backup Linux user home directories
# Author      : Abhishek Shrivastava
# Version     : 1.0
###############################################################################

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backups/daily"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/backup.log"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
HOSTNAME=$(hostname)

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

banner() {

echo "======================================================"
echo "        LinuxOps Enterprise Server"
echo "             Home Backup Manager"
echo "======================================================"

}

backup_user() {

USER_NAME=$1

if ! id "$USER_NAME" &>/dev/null
then
    log "ERROR : User '$USER_NAME' does not exist."
    return
fi

HOME_DIR=$(eval echo "~$USER_NAME")

if [ ! -d "$HOME_DIR" ]
then
    log "ERROR : Home directory not found."
    return
fi

ARCHIVE="$BACKUP_DIR/${USER_NAME}_${DATE}.tar.gz"

log "Backing up $HOME_DIR"

tar -czpf "$ARCHIVE" "$HOME_DIR"

if [ $? -eq 0 ]
then

SIZE=$(du -sh "$ARCHIVE" | awk '{print $1}')

log "SUCCESS : Backup completed"
log "Archive : $ARCHIVE"
log "Size    : $SIZE"

else

log "ERROR : Backup failed."

fi

}

backup_all_users() {

log "Starting full home backup..."

for dir in /home/*
do

if [ -d "$dir" ]
then

USERNAME=$(basename "$dir")

ARCHIVE="$BACKUP_DIR/${USERNAME}_${DATE}.tar.gz"

tar -czpf "$ARCHIVE" "$dir"

SIZE=$(du -sh "$ARCHIVE" | awk '{print $1}')

log "Backed up $USERNAME ($SIZE)"

fi

done

log "All users backed up successfully."

}

show_backups() {

echo
echo "Available Backups"
echo "---------------------------------------------"

ls -lh "$BACKUP_DIR"

echo

}

backup_with_rsync() {

USER_NAME=$1

if ! id "$USER_NAME" &>/dev/null
then
    log "ERROR : User not found."
    return
fi

HOME_DIR=$(eval echo "~$USER_NAME")

DEST="$BACKUP_DIR/${USER_NAME}_latest"

mkdir -p "$DEST"

rsync -av --delete "$HOME_DIR/" "$DEST/"

log "Incremental rsync backup completed."

}

cleanup_old_backups() {

echo
read -p "Delete backups older than how many days? : " DAYS

find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +"$DAYS" -exec rm -f {} \;

log "Old backups removed."

}

backup_size() {

echo
echo "Backup Storage Usage"
echo "--------------------------------"

du -sh "$BACKUP_DIR"

echo

}

menu() {

while true

do

echo
echo "============== Backup Menu =============="
echo "1. Backup Single User"
echo "2. Backup All Users"
echo "3. Incremental Backup (rsync)"
echo "4. Show Available Backups"
echo "5. Backup Storage Usage"
echo "6. Cleanup Old Backups"
echo "7. Exit"
echo "========================================="

read -p "Select Option : " CHOICE

case $CHOICE in

1)

read -p "Enter Username : " USERNAME

backup_user "$USERNAME"

;;

2)

backup_all_users

;;

3)

read -p "Enter Username : " USERNAME

backup_with_rsync "$USERNAME"

;;

4)

show_backups

;;

5)

backup_size

;;

6)

cleanup_old_backups

;;

7)

echo

echo "Goodbye."

exit 0

;;

*)

echo

echo "Invalid Option."

;;

esac

done

}

banner
menu