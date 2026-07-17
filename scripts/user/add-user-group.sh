#!/bin/bash

###############################################################################
# LinuxOps Enterprise Server
# File: scripts/user/add-user-group.sh
# Description: Add an existing Linux user to an existing Linux group
###############################################################################

LOG_FILE="../../logs/users.log"

#------------------------------------------------------------------------------
# Create log directory if it does not exist
#------------------------------------------------------------------------------

mkdir -p ../../logs

#------------------------------------------------------------------------------
# Logging Function
#------------------------------------------------------------------------------

log_action() {

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"

}

#------------------------------------------------------------------------------
# Root Check
#------------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo
    echo "This script must be run as root."
    echo
    echo "Example:"
    echo "sudo ./add-user-group.sh"
    exit 1
fi

#------------------------------------------------------------------------------
# Header
#------------------------------------------------------------------------------

clear

echo "==============================================="
echo "     LinuxOps Enterprise Server"
echo "          Add User To Group"
echo "==============================================="
echo

#------------------------------------------------------------------------------
# User Input
#------------------------------------------------------------------------------

read -rp "Enter Username : " USERNAME
echo
read -rp "Enter Group Name : " GROUPNAME
echo

#------------------------------------------------------------------------------
# Validate User
#------------------------------------------------------------------------------

if ! id "$USERNAME" >/dev/null 2>&1; then

    echo "User '$USERNAME' does not exist."

    log_action "FAILED : User $USERNAME not found."

    exit 1

fi

#------------------------------------------------------------------------------
# Validate Group
#------------------------------------------------------------------------------

if ! getent group "$GROUPNAME" >/dev/null 2>&1; then

    echo "Group '$GROUPNAME' does not exist."

    log_action "FAILED : Group $GROUPNAME not found."

    exit 1

fi

#------------------------------------------------------------------------------
# Check Existing Membership
#------------------------------------------------------------------------------

if id -nG "$USERNAME" | grep -qw "$GROUPNAME"; then

    echo
    echo "User '$USERNAME' already belongs to '$GROUPNAME'."

    log_action "INFO : $USERNAME already belongs to $GROUPNAME."

    exit 0

fi

#------------------------------------------------------------------------------
# Add User To Group
#------------------------------------------------------------------------------

usermod -aG "$GROUPNAME" "$USERNAME"

#------------------------------------------------------------------------------
# Verify Result
#------------------------------------------------------------------------------

if id -nG "$USERNAME" | grep -qw "$GROUPNAME"; then

    echo
    echo "==============================================="
    echo "User successfully added to group."
    echo "==============================================="
    echo

    echo "Username : $USERNAME"
    echo "Group    : $GROUPNAME"

    echo
    echo "Current Groups:"
    id -nG "$USERNAME"

    log_action "SUCCESS : Added $USERNAME to $GROUPNAME"

else

    echo
    echo "Failed to add user to group."

    log_action "FAILED : Could not add $USERNAME to $GROUPNAME"

    exit 1

fi

echo
echo "Done."
echo