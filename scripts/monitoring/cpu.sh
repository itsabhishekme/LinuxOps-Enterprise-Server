#!/bin/bash

################################################################################
# LinuxOps Enterprise Server
# File: scripts/monitoring/cpu.sh
# Description: CPU Monitoring Script
# Author: Abhishek Shrivastava
################################################################################

LOG_DIR="../../logs"
REPORT_DIR="../../reports"

LOG_FILE="$LOG_DIR/monitor.log"
REPORT_FILE="$REPORT_DIR/cpu-report.txt"

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

TOTAL_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')

CPU_MODEL=$(lscpu | grep "Model name" | sed 's/Model name:[[:space:]]*//')

CPU_CORES=$(nproc)

CPU_ARCH=$(uname -m)

CPU_FREQ=$(lscpu | grep "CPU MHz" | awk '{print $3}')

CPU_TEMP="N/A"

if command -v sensors >/dev/null 2>&1
then
    CPU_TEMP=$(sensors | grep -m1 "Package id 0" | awk '{print $4}')
fi

echo "===================================================" > "$REPORT_FILE"
echo " LinuxOps Enterprise Server - CPU Report" >> "$REPORT_FILE"
echo "===================================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Generated : $TIMESTAMP" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "CPU Model        : $CPU_MODEL" >> "$REPORT_FILE"
echo "Architecture     : $CPU_ARCH" >> "$REPORT_FILE"
echo "CPU Cores        : $CPU_CORES" >> "$REPORT_FILE"
echo "CPU Frequency    : $CPU_FREQ MHz" >> "$REPORT_FILE"
echo "CPU Temperature  : $CPU_TEMP" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "Current Usage    : $TOTAL_USAGE %" >> "$REPORT_FILE"

echo "Load Average     : $LOAD_AVG" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "Top CPU Processes" >> "$REPORT_FILE"
echo "-----------------------------" >> "$REPORT_FILE"

ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -11 >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

if (( $(echo "$TOTAL_USAGE > 90" | bc -l) ))
then
    STATUS="CRITICAL"
elif (( $(echo "$TOTAL_USAGE > 75" | bc -l) ))
then
    STATUS="WARNING"
else
    STATUS="NORMAL"
fi

echo "CPU Status : $STATUS" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

echo "[$TIMESTAMP] CPU Usage: $TOTAL_USAGE % | Status: $STATUS" >> "$LOG_FILE"

echo "==================================================="
echo " LinuxOps Enterprise Server"
echo " CPU Monitoring"
echo "==================================================="

echo ""

echo "Time             : $TIMESTAMP"
echo "CPU Model        : $CPU_MODEL"
echo "Architecture     : $CPU_ARCH"
echo "CPU Cores        : $CPU_CORES"
echo "Frequency        : $CPU_FREQ MHz"
echo "Temperature      : $CPU_TEMP"
echo ""

echo "CPU Usage        : $TOTAL_USAGE %"
echo "Load Average     : $LOAD_AVG"
echo "Status           : $STATUS"

echo ""

echo "Top CPU Processes"

echo "---------------------------------------------------"

ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -11

echo ""

echo "CPU report saved to:"
echo "$REPORT_FILE"

echo ""

echo "Log updated:"
echo "$LOG_FILE"

echo ""

if [ "$STATUS" = "CRITICAL" ]
then
    echo "⚠ CRITICAL CPU USAGE"
elif [ "$STATUS" = "WARNING" ]
then
    echo "⚠ WARNING CPU USAGE"
else
    echo "✓ CPU is Healthy"
fi

echo ""

exit 0