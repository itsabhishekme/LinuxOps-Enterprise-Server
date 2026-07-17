#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# Module      : Port Scanner
# File        : localhost.sh
# Description : Scan localhost ports using Nmap
# Author      : Abhishek Shrivastava
# ============================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/reports"
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$REPORT_DIR"
mkdir -p "$LOG_DIR"

REPORT_FILE="$REPORT_DIR/localhost-port-scan.txt"
LOG_FILE="$LOG_DIR/server.log"

line() {
    printf '=%.0s' {1..70}
    echo
}

header() {
    clear
    line
    echo "        LinuxOps Enterprise Server"
    echo "        Localhost Port Scanner"
    line
}

check_nmap() {

    if ! command -v nmap >/dev/null 2>&1; then

        echo "Nmap is not installed."
        echo

        read -rp "Install nmap now? (y/n): " ans

        case "$ans" in
            y|Y)

                sudo apt update
                sudo apt install -y nmap
                ;;

            *)

                echo "Cannot continue without nmap."
                exit 1
                ;;

        esac

    fi

}

write_log() {

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Localhost port scan completed." >> "$LOG_FILE"

}

run_scan() {

    echo
    echo "Scanning localhost..."
    echo

    sudo nmap \
        -sS \
        -sV \
        -O \
        -Pn \
        localhost \
        -oN "$REPORT_FILE"

}

show_summary() {

    echo
    line

    echo "Open Ports"

    grep "/tcp" "$REPORT_FILE" || true

    line

    echo "Report Saved"

    echo "$REPORT_FILE"

    line

}

show_report() {

    echo
    read -rp "View complete report? (y/n): " choice

    case "$choice" in

        y|Y)

            less "$REPORT_FILE"
            ;;

        *)

            ;;

    esac

}

export_report() {

    echo
    read -rp "Copy report to Desktop? (y/n): " choice

    case "$choice" in

        y|Y)

            if [ -d "$HOME/Desktop" ]; then

                cp "$REPORT_FILE" "$HOME/Desktop/"

                echo
                echo "Report copied to Desktop."

            else

                echo
                echo "Desktop directory not found."

            fi

            ;;

        *)

            ;;

    esac

}

footer() {

    echo
    line
    echo "Scan Finished Successfully."
    line
    echo

}

main() {

    header

    check_nmap

    run_scan

    write_log

    show_summary

    show_report

    export_report

    footer

}

main