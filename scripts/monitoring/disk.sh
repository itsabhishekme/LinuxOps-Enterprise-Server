#!/bin/bash

# ==========================================================
# LinuxOps Enterprise Server
# File: scripts/monitoring/disk.sh
# Description: Disk Usage Monitoring Script
# Author: Abhishek Shrivastava
# ==========================================================

LOG_DIR="../../logs"
REPORT_DIR="../../reports"

LOG_FILE="$LOG_DIR/monitor.log"
REPORT_FILE="$REPORT_DIR/disk-report.txt"

WARNING=80
CRITICAL=90

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "==========================================" > "$REPORT_FILE"
echo "      LinuxOps Disk Usage Report" >> "$REPORT_FILE"
echo "==========================================" >> "$REPORT_FILE"
echo "Generated : $TIMESTAMP" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Hostname : $(hostname)" >> "$REPORT_FILE"
echo "Kernel   : $(uname -r)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Mounted Filesystems" >> "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"

df -h >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "Filesystem Health" >> "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"

df -hP | awk 'NR>1 {print $1,$5,$6}' | while read FS USE MOUNT
do

    USAGE=$(echo "$USE" | tr -d '%')

    STATUS="Healthy"

    if [ "$USAGE" -ge "$CRITICAL" ]; then
        STATUS="CRITICAL"
    elif [ "$USAGE" -ge "$WARNING" ]; then
        STATUS="WARNING"
    fi

    printf "%-25s %-8s %-25s %s\n" "$FS" "$USE" "$MOUNT" "$STATUS" >> "$REPORT_FILE"

done

echo "" >> "$REPORT_FILE"

echo "Top 10 Largest Directories (/)" >> "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"

du -xh / 2>/dev/null | sort -rh | head -10 >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "Top 10 Largest Files (/)" >> "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"

find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -10 >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "Disk I/O Statistics" >> "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"

if command -v iostat >/dev/null 2>&1
then
    iostat >> "$REPORT_FILE"
else
    echo "iostat not installed." >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

echo "Inode Usage" >> "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"

df -ih >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "Disk Monitoring Summary" >> "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"

TOTAL_FILESYSTEMS=0
WARNING_COUNT=0
CRITICAL_COUNT=0

while read FS USE MOUNT
do

    USAGE=$(echo "$USE" | tr -d '%')

    TOTAL_FILESYSTEMS=$((TOTAL_FILESYSTEMS + 1))

    if [ "$USAGE" -ge "$CRITICAL" ]; then
        CRITICAL_COUNT=$((CRITICAL_COUNT + 1))
    elif [ "$USAGE" -ge "$WARNING" ]; then
        WARNING_COUNT=$((WARNING_COUNT + 1))
    fi

done < <(df -hP | awk 'NR>1 {print $1,$5,$6}')

echo "Total Filesystems : $TOTAL_FILESYSTEMS" >> "$REPORT_FILE"
echo "Warning           : $WARNING_COUNT" >> "$REPORT_FILE"
echo "Critical          : $CRITICAL_COUNT" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

if [ "$CRITICAL_COUNT" -gt 0 ]
then
    OVERALL="CRITICAL"
elif [ "$WARNING_COUNT" -gt 0 ]
then
    OVERALL="WARNING"
else
    OVERALL="HEALTHY"
fi

echo "Overall Status : $OVERALL" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "[$TIMESTAMP] Disk Report Generated - Status: $OVERALL" >> "$LOG_FILE"

echo ""
echo "=========================================="
echo " LinuxOps Enterprise Server"
echo " Disk Monitoring Completed"
echo "=========================================="
echo ""
echo "Overall Status : $OVERALL"
echo "Report Saved   : $REPORT_FILE"
echo "Log Updated    : $LOG_FILE"
echo ""