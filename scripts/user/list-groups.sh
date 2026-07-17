#!/bin/bash

###############################################################################
# Project : LinuxOps Enterprise Server
# Module  : User Management
# Script  : list-groups.sh
# Author  : Abhishek Shrivastava
# Version : 1.0
#
# Description:
# Lists all Linux groups with useful information including:
# - Group Name
# - GID
# - Members
# - Total Groups
# - Search Group
# - Export Report
###############################################################################

LOG_DIR="../../logs"
REPORT_DIR="../../reports"

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

LOG_FILE="$LOG_DIR/users.log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
WHITE="\e[97m"
NC="\e[0m"

pause() {
    echo
    read -rp "Press Enter to continue..."
}

header() {
    clear
    echo -e "${CYAN}"
    echo "=============================================================="
    echo "              LinuxOps Enterprise Server"
    echo "                 Group Management"
    echo "=============================================================="
    echo -e "${NC}"
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

list_groups() {

    header

    printf "%-30s %-10s %-40s\n" "GROUP" "GID" "MEMBERS"

    echo "----------------------------------------------------------------------------------------------"

    while IFS=: read -r group password gid members
    do

        if [ -z "$members" ]; then
            members="-"
        fi

        printf "%-30s %-10s %-40s\n" "$group" "$gid" "$members"

    done < /etc/group

    total=$(cut -d: -f1 /etc/group | wc -l)

    echo
    echo -e "${GREEN}Total Groups : $total${NC}"

    log_action "Displayed all groups"

    pause
}

search_group() {

    header

    read -rp "Enter Group Name: " group

    if grep -q "^$group:" /etc/group
    then

        echo

        grep "^$group:" /etc/group | while IFS=: read -r g p gid members
        do
            echo -e "${GREEN}Group Name : $g${NC}"
            echo "GID        : $gid"

            if [ -z "$members" ]; then
                echo "Members    : None"
            else
                echo "Members    : $members"
            fi
        done

        log_action "Searched group: $group"

    else

        echo
        echo -e "${RED}Group not found.${NC}"

    fi

    pause
}

export_report() {

    header

    REPORT="$REPORT_DIR/group-report.txt"

    {
        echo "===================================================="
        echo "LinuxOps Enterprise Server"
        echo "Group Report"
        echo "Generated: $(date)"
        echo "===================================================="
        echo

        printf "%-30s %-10s %-40s\n" "GROUP" "GID" "MEMBERS"

        echo "----------------------------------------------------------------------------------------------"

        while IFS=: read -r group password gid members
        do

            if [ -z "$members" ]; then
                members="-"
            fi

            printf "%-30s %-10s %-40s\n" "$group" "$gid" "$members"

        done < /etc/group

        echo
        echo "Total Groups : $(cut -d: -f1 /etc/group | wc -l)"

    } > "$REPORT"

    echo
    echo -e "${GREEN}Report saved:${NC}"
    echo "$REPORT"

    log_action "Generated group report"

    pause
}

group_statistics() {

    header

    echo "System Group Statistics"
    echo

    echo "Total Groups:"
    cut -d: -f1 /etc/group | wc -l

    echo
    echo "Groups with Members:"
    grep -v ':$' /etc/group | wc -l

    echo
    echo "Empty Groups:"
    grep ':$' /etc/group | wc -l

    pause
}

while true
do

    header

    echo "1. List All Groups"
    echo "2. Search Group"
    echo "3. Group Statistics"
    echo "4. Export Report"
    echo "5. Exit"

    echo

    read -rp "Choose Option: " option

    case $option in

        1)
            list_groups
            ;;

        2)
            search_group
            ;;

        3)
            group_statistics
            ;;

        4)
            export_report
            ;;

        5)
            clear
            exit 0
            ;;

        *)
            echo
            echo -e "${RED}Invalid Option${NC}"
            sleep 2
            ;;
    esac

done