#!/bin/bash

# ==========================================================
# LinuxOps Enterprise Server
# Module : Network Monitoring
# File   : scripts/monitoring/network.sh
# Author : Abhishek Shrivastava
# ==========================================================

LOG_DIR="../../logs"
REPORT_DIR="../../reports"

LOG_FILE="$LOG_DIR/monitor.log"
REPORT_FILE="$REPORT_DIR/network-report.txt"

mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

clear

echo "============================================================"
echo "            LinuxOps Enterprise Server"
echo "                 Network Monitor"
echo "============================================================"
echo

##############################
# Host Information
##############################

HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
KERNEL=$(uname -r)

##############################
# Default Gateway
##############################

GATEWAY=$(ip route | grep default | awk '{print $3}')

##############################
# DNS Servers
##############################

DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}')

##############################
# Active Interface
##############################

INTERFACE=$(ip route | grep default | awk '{print $5}')

##############################
# Network Statistics
##############################

RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null)
TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null)

##############################
# Ping Test
##############################

ping -c 2 8.8.8.8 >/dev/null 2>&1

if [ $? -eq 0 ]
then
    INTERNET="Connected"
else
    INTERNET="Disconnected"
fi

##############################
# Open Listening Ports
##############################

OPEN_PORTS=$(ss -tuln | tail -n +2 | wc -l)

##############################
# Established Connections
##############################

ESTABLISHED=$(ss -tan state established | tail -n +2 | wc -l)

##############################
# Print Information
##############################

echo "Hostname                : $HOSTNAME"
echo "Kernel                  : $KERNEL"
echo "IP Address              : $IP_ADDRESS"
echo "Network Interface       : $INTERFACE"
echo "Gateway                 : $GATEWAY"

echo
echo "DNS Servers"
echo "----------------------------"

grep nameserver /etc/resolv.conf

echo

echo "Internet Status         : $INTERNET"
echo "Listening Ports         : $OPEN_PORTS"
echo "Established Sessions    : $ESTABLISHED"

echo
echo "Traffic Statistics"
echo "----------------------------"

echo "Received Bytes          : $RX_BYTES"
echo "Transmitted Bytes       : $TX_BYTES"

echo
echo "Network Interfaces"
echo "----------------------------"

ip -brief address

echo
echo "Routing Table"
echo "----------------------------"

ip route

echo
echo "Listening Ports"
echo "----------------------------"

ss -tuln

echo
echo "Active Connections"
echo "----------------------------"

ss -tun

##############################
# Save Report
##############################

{

echo "==================================================="
echo "LinuxOps Enterprise Server"
echo "Network Monitoring Report"
echo "Generated : $TIMESTAMP"
echo "==================================================="

echo
echo "Hostname: $HOSTNAME"
echo "Kernel: $KERNEL"
echo "IP Address: $IP_ADDRESS"
echo "Interface: $INTERFACE"
echo "Gateway: $GATEWAY"

echo
echo "Internet: $INTERNET"

echo
echo "Received Bytes: $RX_BYTES"
echo "Transmitted Bytes: $TX_BYTES"

echo
echo "Listening Ports: $OPEN_PORTS"

echo
echo "Established Connections: $ESTABLISHED"

echo
echo "DNS Servers"

grep nameserver /etc/resolv.conf

echo
echo "Interfaces"

ip -brief address

echo
echo "Routing Table"

ip route

echo
echo "Listening Ports"

ss -tuln

echo
echo "Connections"

ss -tun

} > "$REPORT_FILE"

##############################
# Log Activity
##############################

echo "[$TIMESTAMP] Network monitoring completed." >> "$LOG_FILE"

echo
echo "============================================================"
echo " Network monitoring completed successfully."
echo
echo " Report Saved : $REPORT_FILE"
echo " Log Updated  : $LOG_FILE"
echo "============================================================"
echo