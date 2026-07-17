#!/bin/bash

################################################################################
# File        : ram.sh
# Project     : LinuxOps Enterprise Server
# Description : Memory (RAM & Swap) Monitoring Script
# Author      : Abhishek Shrivastava
# Version     : 1.0
################################################################################

LOG_DIR="../../logs"
REPORT_DIR="../../reports"

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

LOG_FILE="$LOG_DIR/monitor.log"
REPORT_FILE="$REPORT_DIR/memory-report.txt"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

TOTAL_RAM=$(free -m | awk '/Mem:/ {print $2}')
USED_RAM=$(free -m | awk '/Mem:/ {print $3}')
FREE_RAM=$(free -m | awk '/Mem:/ {print $4}')
AVAILABLE_RAM=$(free -m | awk '/Mem:/ {print $7}')

TOTAL_SWAP=$(free -m | awk '/Swap:/ {print $2}')
USED_SWAP=$(free -m | awk '/Swap:/ {print $3}')
FREE_SWAP=$(free -m | awk '/Swap:/ {print $4}')

RAM_PERCENT=$(( USED_RAM * 100 / TOTAL_RAM ))

echo "==================================================" | tee "$REPORT_FILE"
echo "        LinuxOps Enterprise Server" | tee -a "$REPORT_FILE"
echo "            Memory Usage Report" | tee -a "$REPORT_FILE"
echo "==================================================" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo "Generated : $TIMESTAMP" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo "RAM INFORMATION" | tee -a "$REPORT_FILE"
echo "---------------" | tee -a "$REPORT_FILE"
echo "Total RAM     : ${TOTAL_RAM} MB" | tee -a "$REPORT_FILE"
echo "Used RAM      : ${USED_RAM} MB" | tee -a "$REPORT_FILE"
echo "Free RAM      : ${FREE_RAM} MB" | tee -a "$REPORT_FILE"
echo "Available RAM : ${AVAILABLE_RAM} MB" | tee -a "$REPORT_FILE"
echo "Usage         : ${RAM_PERCENT}%" | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"

echo "SWAP INFORMATION" | tee -a "$REPORT_FILE"
echo "----------------" | tee -a "$REPORT_FILE"
echo "Total Swap : ${TOTAL_SWAP} MB" | tee -a "$REPORT_FILE"
echo "Used Swap  : ${USED_SWAP} MB" | tee -a "$REPORT_FILE"
echo "Free Swap  : ${FREE_SWAP} MB" | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"

echo "TOP MEMORY CONSUMING PROCESSES" | tee -a "$REPORT_FILE"
echo "------------------------------" | tee -a "$REPORT_FILE"

ps -eo pid,user,%mem,%cpu,comm --sort=-%mem | head -11 | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"

echo "MEMORY STATUS"

if [ "$RAM_PERCENT" -lt 60 ]; then

    STATUS="Healthy"
    echo "Status : Healthy"
    echo "Memory usage is within normal range."

elif [ "$RAM_PERCENT" -lt 80 ]; then

    STATUS="Warning"
    echo "Status : Warning"
    echo "Memory usage is moderately high."

else

    STATUS="Critical"
    echo "Status : Critical"
    echo "High memory usage detected."

fi

echo "" | tee -a "$REPORT_FILE"

echo "SYSTEM UPTIME" | tee -a "$REPORT_FILE"
echo "-------------" | tee -a "$REPORT_FILE"
uptime | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"

echo "FREE COMMAND OUTPUT" | tee -a "$REPORT_FILE"
echo "-------------------" | tee -a "$REPORT_FILE"
free -h | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"

echo "[$TIMESTAMP] RAM Usage : ${RAM_PERCENT}% | Status : ${STATUS}" >> "$LOG_FILE"

echo ""
echo "Report saved to:"
echo "$REPORT_FILE"

echo ""
echo "Log updated:"
echo "$LOG_FILE"