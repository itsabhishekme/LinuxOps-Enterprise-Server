#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/backup/cleanup.sh
# Description:
# Remove old backup files from daily, weekly and monthly backup folders.
###############################################################################

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

BACKUP_DIR="$PROJECT_ROOT/backups"

DAILY_DIR="$BACKUP_DIR/daily"
WEEKLY_DIR="$BACKUP_DIR/weekly"
MONTHLY_DIR="$BACKUP_DIR/monthly"

LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/backup.log"

# Retention Policy
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=12

###############################################################################

create_log_dir() {

    mkdir -p "$LOG_DIR"

}

###############################################################################

log() {

    create_log_dir

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"

}

###############################################################################

banner() {

echo "========================================================="
echo "        LinuxOps Enterprise Server"
echo "             Backup Cleanup Utility"
echo "========================================================="

}

###############################################################################

count_files() {

    local folder="$1"

    find "$folder" -type f | wc -l

}

###############################################################################

delete_old_files() {

    local folder="$1"
    local keep="$2"

    mkdir -p "$folder"

    total=$(count_files "$folder")

    if [ "$total" -le "$keep" ]; then

        log "Nothing to clean in $folder (Files: $total)"

        return

    fi

    remove=$((total-keep))

    log "Removing $remove old backup(s) from $folder"

    find "$folder" -type f \
    -printf "%T@ %p\n" \
    | sort -n \
    | head -n "$remove" \
    | cut -d' ' -f2- \
    | while read file
    do

        rm -f "$file"

        log "Deleted: $file"

    done

}

###############################################################################

disk_usage() {

echo
echo "Current Backup Disk Usage"
echo "-------------------------"

du -sh "$BACKUP_DIR"

echo

}

###############################################################################

list_backups() {

echo
echo "Existing Backups"
echo "----------------"

find "$BACKUP_DIR" -type f

echo

}

###############################################################################

summary() {

echo
echo "--------------------------------------"
echo "Cleanup Summary"
echo "--------------------------------------"

echo "Daily Backups   : $(count_files "$DAILY_DIR")"

echo "Weekly Backups  : $(count_files "$WEEKLY_DIR")"

echo "Monthly Backups : $(count_files "$MONTHLY_DIR")"

echo "--------------------------------------"

}

###############################################################################

main() {

banner

log "Backup cleanup started"

disk_usage

delete_old_files "$DAILY_DIR" "$DAILY_KEEP"

delete_old_files "$WEEKLY_DIR" "$WEEKLY_KEEP"

delete_old_files "$MONTHLY_DIR" "$MONTHLY_KEEP"

summary

list_backups

disk_usage

log "Backup cleanup completed"

}

###############################################################################

main