#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File: scripts/user/create-group.sh
# Description: Create a new Linux group safely.
# Author: Abhishek Shrivastava
# ============================================================

set -e

LOG_DIR="$(dirname "$0")/../../logs"
LOG_FILE="$LOG_DIR/users.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

header() {
    clear
    echo "======================================================"
    echo "        LinuxOps Enterprise Server"
    echo "            Create Linux Group"
    echo "======================================================"
    echo
}

pause() {
    echo
    read -rp "Press Enter to continue..."
}

# Check root privilege
if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run this script as root."
    echo
    echo "Example:"
    echo "sudo ./create-group.sh"
    exit 1
fi

header

read -rp "Enter Group Name: " GROUP_NAME

# Validate input
if [[ -z "$GROUP_NAME" ]]; then
    echo
    echo "❌ Group name cannot be empty."
    pause
    exit 1
fi

# Allow only valid Linux group names
if [[ ! "$GROUP_NAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo
    echo "❌ Invalid group name."
    echo "Allowed:"
    echo "  - Lowercase letters"
    echo "  - Numbers"
    echo "  - Underscore (_)"
    echo "  - Hyphen (-)"
    pause
    exit 1
fi

# Check if group exists
if getent group "$GROUP_NAME" > /dev/null; then
    echo
    echo "⚠ Group '$GROUP_NAME' already exists."
    log "Attempt to create existing group: $GROUP_NAME"
    pause
    exit 0
fi

echo
echo "Creating group..."

if groupadd "$GROUP_NAME"; then
    echo
    echo "✅ Group created successfully."
    echo
    echo "Group Name : $GROUP_NAME"
    echo "Group ID   : $(getent group "$GROUP_NAME" | cut -d: -f3)"
    echo

    log "Group created: $GROUP_NAME"

else
    echo
    echo "❌ Failed to create group."
    log "Failed to create group: $GROUP_NAME"
    exit 1
fi

echo "--------------------------------------------"
echo "Current Group Information"
echo "--------------------------------------------"

getent group "$GROUP_NAME"

echo
echo "--------------------------------------------"
echo "Last 10 Groups"
echo "--------------------------------------------"

tail -10 /etc/group | cut -d: -f1

pause
exit 0