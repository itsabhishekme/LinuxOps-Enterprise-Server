#!/bin/bash

# ==========================================================
# LinuxOps Enterprise Server
# File: scripts/user/reset-password.sh
# Description: Reset the password for an existing Linux user
# Author: Abhishek Shrivastava
# ==========================================================

LOG_FILE="../../logs/users.log"

# ----------------------------------------------------------
# Create log directory if it doesn't exist
# ----------------------------------------------------------
mkdir -p ../../logs

# ----------------------------------------------------------
# Logging Function
# ----------------------------------------------------------
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ----------------------------------------------------------
# Banner
# ----------------------------------------------------------
clear

echo "=================================================="
echo "        LinuxOps Enterprise Server"
echo "            Reset User Password"
echo "=================================================="
echo

# ----------------------------------------------------------
# Check for Root
# ----------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root."
    echo
    echo "Run:"
    echo "sudo ./reset-password.sh"
    exit 1
fi

# ----------------------------------------------------------
# Username Input
# ----------------------------------------------------------
read -rp "Enter username: " USERNAME

if [ -z "$USERNAME" ]; then
    echo
    echo "❌ Username cannot be empty."
    exit 1
fi

# ----------------------------------------------------------
# Check User Exists
# ----------------------------------------------------------
if ! id "$USERNAME" &>/dev/null; then
    echo
    echo "❌ User '$USERNAME' does not exist."
    log_message "Password reset failed. User '$USERNAME' not found."
    exit 1
fi

echo
echo "User Found:"
echo "-------------------------------"
id "$USERNAME"
echo

# ----------------------------------------------------------
# Password Choice
# ----------------------------------------------------------
echo "Password Options"
echo "----------------"
echo "1. Enter password manually"
echo "2. Generate random password"
echo

read -rp "Choose option (1-2): " OPTION

case "$OPTION" in

1)

    echo
    passwd "$USERNAME"

    if [ $? -eq 0 ]; then
        echo
        echo "✅ Password updated successfully."
        log_message "Password manually reset for '$USERNAME'."
    else
        echo
        echo "❌ Failed to update password."
        log_message "Password reset failed for '$USERNAME'."
        exit 1
    fi

    ;;

2)

    PASSWORD=$(openssl rand -base64 12)

    echo "${USERNAME}:${PASSWORD}" | chpasswd

    if [ $? -eq 0 ]; then

        echo
        echo "========================================="
        echo "Password Reset Successful"
        echo "========================================="
        echo
        echo "Username : $USERNAME"
        echo "Password : $PASSWORD"
        echo
        echo "Please change this password after login."
        echo

        log_message "Random password generated for '$USERNAME'."

    else

        echo
        echo "❌ Failed to reset password."

        log_message "Random password reset failed for '$USERNAME'."

        exit 1

    fi

    ;;

*)

    echo
    echo "❌ Invalid option."

    exit 1

    ;;

esac

# ----------------------------------------------------------
# Password Expiry Option
# ----------------------------------------------------------
echo
read -rp "Force password change on next login? (y/n): " FORCE

case "$FORCE" in

y|Y)

    chage -d 0 "$USERNAME"

    echo
    echo "✅ User must change password on next login."

    log_message "Password expiry enabled for '$USERNAME'."

    ;;

*)

    echo
    echo "Password expiry not enabled."

    ;;

esac

# ----------------------------------------------------------
# User Information
# ----------------------------------------------------------
echo
echo "========================================="
echo "User Information"
echo "========================================="

id "$USERNAME"

echo

passwd -S "$USERNAME"

echo

echo "========================================="
echo "Operation Completed Successfully"
echo "========================================="

log_message "Password reset completed successfully for '$USERNAME'."

exit 0