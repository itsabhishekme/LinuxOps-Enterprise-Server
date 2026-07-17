#!/bin/bash

# ==========================================================
# LinuxOps Enterprise Server
# File        : backup-system.sh
# Description : Complete Linux System Backup Utility
# Author      : Abhishek Shrivastava
# Version     : 1.0
# ==========================================================

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
HOSTNAME=$(hostname)

SYSTEM_BACKUP="$BACKUP_DIR/system-$HOSTNAME-$TIMESTAMP"

mkdir -p "$SYSTEM_BACKUP"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

header() {
    echo
    echo "===================================================="
    echo "        LinuxOps Enterprise Server"
    echo "          System Backup Utility"
    echo "===================================================="
    echo
}

backup_directory() {

    SOURCE=$1
    NAME=$2

    if [ -d "$SOURCE" ]; then

        log "Backing up $SOURCE"

        rsync -aAX --delete \
            --exclude="*.tmp" \
            --exclude="*.cache" \
            "$SOURCE" \
            "$SYSTEM_BACKUP/$NAME"

        log "$SOURCE completed."

    else

        log "$SOURCE not found. Skipping."

    fi

}

backup_file() {

    FILE=$1

    if [ -f "$FILE" ]; then

        cp "$FILE" "$SYSTEM_BACKUP"

        log "$FILE copied."

    fi

}

system_information() {

cat <<EOF > "$SYSTEM_BACKUP/system-info.txt"

===============================
LinuxOps Enterprise Server
System Information
===============================

Hostname:
$(hostname)

Current User:
$(whoami)

Kernel:
$(uname -r)

Operating System:
$(cat /etc/os-release)

CPU:
$(lscpu)

Memory:
$(free -h)

Disk:
$(df -h)

Mounted Drives:
$(lsblk)

Network:
$(ip addr)

Running Since:
$(uptime)

Date:
$(date)

EOF

}

compress_backup() {

    cd "$BACKUP_DIR"

    tar -czf \
    "$(basename "$SYSTEM_BACKUP").tar.gz" \
    "$(basename "$SYSTEM_BACKUP")"

    rm -rf "$SYSTEM_BACKUP"

    log "Backup compressed."

}

show_summary() {

echo
echo "========================================="
echo "Backup Completed Successfully"
echo "========================================="

echo

echo "Backup File"

ls -lh "$BACKUP_DIR"/*.tar.gz | tail -1

echo

echo "Backup Log"

echo "$LOG_FILE"

echo

}

header

log "Starting Full System Backup"

backup_directory "/etc" "etc"

backup_directory "/home" "home"

backup_directory "/var/www" "www"

backup_directory "/opt" "opt"

backup_directory "/usr/local/bin" "usr-local-bin"

backup_directory "/root" "root"

backup_file "/etc/fstab"

backup_file "/etc/passwd"

backup_file "/etc/group"

backup_file "/etc/shadow"

backup_file "/etc/hosts"

backup_file "/etc/hostname"

backup_file "/etc/crontab"

system_information

compress_backup

log "Backup Finished Successfully"

show_summary