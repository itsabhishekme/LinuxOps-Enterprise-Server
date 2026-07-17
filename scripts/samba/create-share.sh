#!/bin/bash

#############################################################
# LinuxOps Enterprise Server
# File: scripts/samba/create-share.sh
# Description: Create and Configure a Samba Shared Folder
# Author: Abhishek Shrivastava
#############################################################

set -e

CONFIG_FILE="/etc/samba/smb.conf"

echo "========================================"
echo " LinuxOps Enterprise Server"
echo " Samba Share Creator"
echo "========================================"
echo

# Root Permission Check
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root."
    echo
    echo "Example:"
    echo "sudo ./create-share.sh"
    exit 1
fi

# Check Samba Installation
if ! command -v smbd >/dev/null 2>&1; then
    echo "Samba is not installed."
    echo
    echo "Install it using:"
    echo "sudo apt install samba -y"
    exit 1
fi

echo "Enter Share Name:"
read -r SHARE_NAME

if [[ -z "$SHARE_NAME" ]]; then
    echo "Share name cannot be empty."
    exit 1
fi

DEFAULT_PATH="/srv/samba/$SHARE_NAME"

echo
echo "Share Location"
echo "Press Enter to use default:"
echo "$DEFAULT_PATH"
echo

read -r SHARE_PATH

if [[ -z "$SHARE_PATH" ]]; then
    SHARE_PATH="$DEFAULT_PATH"
fi

echo
echo "Create directory..."
mkdir -p "$SHARE_PATH"

echo
echo "Owner Username:"
read -r OWNER

if ! id "$OWNER" >/dev/null 2>&1; then
    echo
    echo "Linux user '$OWNER' does not exist."
    exit 1
fi

chown "$OWNER":"$OWNER" "$SHARE_PATH"
chmod 2775 "$SHARE_PATH"

echo
echo "Public Share?"
echo "1) Yes"
echo "2) No"
read -r PUBLIC

if [[ "$PUBLIC" == "1" ]]; then
    GUEST_OK="yes"
    WRITABLE="yes"
    BROWSEABLE="yes"
    READ_ONLY="no"
else
    GUEST_OK="no"
    WRITABLE="yes"
    BROWSEABLE="yes"
    READ_ONLY="no"
fi

echo
echo "Checking existing configuration..."

if grep -q "^\[$SHARE_NAME\]" "$CONFIG_FILE"; then
    echo
    echo "Share already exists in smb.conf"
    exit 1
fi

echo
echo "Writing configuration..."

cat <<EOF >> "$CONFIG_FILE"

[$SHARE_NAME]
    comment = LinuxOps Enterprise Share
    path = $SHARE_PATH
    browseable = $BROWSEABLE
    writable = $WRITABLE
    read only = $READ_ONLY
    guest ok = $GUEST_OK
    create mask = 0664
    directory mask = 2775
    force user = $OWNER
EOF

echo
echo "Validating Samba configuration..."

testparm -s

echo
echo "Restarting Samba..."

systemctl restart smbd
systemctl enable smbd

echo
echo "========================================"
echo " Samba Share Created Successfully"
echo "========================================"

echo
echo "Share Name:"
echo "   $SHARE_NAME"

echo
echo "Share Path:"
echo "   $SHARE_PATH"

echo
echo "Owner:"
echo "   $OWNER"

echo
echo "Access:"
if [[ "$PUBLIC" == "1" ]]; then
    echo "   Public"
else
    echo "   Authenticated Users"
fi

echo
echo "Current Samba Shares"
echo "----------------------------------------"

grep "^\[" "$CONFIG_FILE"

echo
echo "Directory Information"
echo "----------------------------------------"

ls -ld "$SHARE_PATH"

echo
echo "Service Status"
echo "----------------------------------------"

systemctl --no-pager status smbd | head -10

echo
echo "Done."
exit 0