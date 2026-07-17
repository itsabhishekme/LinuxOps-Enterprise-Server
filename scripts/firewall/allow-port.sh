#!/bin/bash

# ============================================================
# LinuxOps Enterprise Server
# File: scripts/firewall/allow-port.sh
# Description: Allow TCP/UDP ports using UFW
# Author: Abhishek Shrivastava
# ============================================================

LOG_DIR="$(dirname "$0")/../../logs"
LOG_FILE="$LOG_DIR/firewall.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ Please run as root or with sudo."
        exit 1
    fi
}

check_ufw() {
    if ! command -v ufw >/dev/null 2>&1; then
        echo "❌ UFW is not installed."
        echo "Install using:"
        echo "sudo apt update && sudo apt install ufw -y"
        exit 1
    fi
}

enable_firewall() {
    if ! ufw status | grep -q "Status: active"; then
        echo "Firewall is disabled."
        read -rp "Enable firewall now? (y/n): " ans

        case "$ans" in
            y|Y)
                ufw --force enable
                log "Firewall enabled."
                ;;
            *)
                echo "Cannot continue while firewall is disabled."
                exit 1
                ;;
        esac
    fi
}

allow_port() {

    read -rp "Enter Port Number: " PORT

    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        echo "Invalid port."
        return
    fi

    if (( PORT < 1 || PORT > 65535 )); then
        echo "Port must be between 1 and 65535."
        return
    fi

    echo
    echo "1) TCP"
    echo "2) UDP"
    echo "3) Both TCP & UDP"
    echo

    read -rp "Choose Protocol: " CHOICE

    case "$CHOICE" in
        1)
            ufw allow "${PORT}/tcp"
            log "Allowed TCP port ${PORT}"
            echo "✅ TCP Port ${PORT} allowed."
            ;;
        2)
            ufw allow "${PORT}/udp"
            log "Allowed UDP port ${PORT}"
            echo "✅ UDP Port ${PORT} allowed."
            ;;
        3)
            ufw allow "${PORT}/tcp"
            ufw allow "${PORT}/udp"
            log "Allowed TCP/UDP port ${PORT}"
            echo "✅ TCP & UDP Port ${PORT} allowed."
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
}

common_ports() {

    while true
    do
        clear

        echo "===================================="
        echo " Common Firewall Rules"
        echo "===================================="
        echo
        echo "1. SSH (22)"
        echo "2. HTTP (80)"
        echo "3. HTTPS (443)"
        echo "4. FTP (21)"
        echo "5. Samba (445)"
        echo "6. MySQL (3306)"
        echo "7. PostgreSQL (5432)"
        echo "8. Redis (6379)"
        echo "9. Back"
        echo

        read -rp "Select: " OPTION

        case "$OPTION" in

            1)
                ufw allow 22/tcp
                log "Allowed SSH"
                ;;

            2)
                ufw allow 80/tcp
                log "Allowed HTTP"
                ;;

            3)
                ufw allow 443/tcp
                log "Allowed HTTPS"
                ;;

            4)
                ufw allow 21/tcp
                log "Allowed FTP"
                ;;

            5)
                ufw allow 445/tcp
                log "Allowed Samba"
                ;;

            6)
                ufw allow 3306/tcp
                log "Allowed MySQL"
                ;;

            7)
                ufw allow 5432/tcp
                log "Allowed PostgreSQL"
                ;;

            8)
                ufw allow 6379/tcp
                log "Allowed Redis"
                ;;

            9)
                break
                ;;

            *)
                echo "Invalid choice."
                ;;

        esac

        echo
        read -rp "Press Enter to continue..."
    done
}

show_rules() {

    echo
    echo "Current Firewall Rules"
    echo "----------------------------------"

    ufw status numbered

    echo
}

main_menu() {

    while true
    do

        clear

        echo "==========================================="
        echo " LinuxOps Enterprise Firewall Manager"
        echo "==========================================="
        echo
        echo "1. Allow Custom Port"
        echo "2. Allow Common Service"
        echo "3. View Firewall Rules"
        echo "4. Exit"
        echo

        read -rp "Choose: " MENU

        case "$MENU" in

            1)
                allow_port
                read -rp "Press Enter..."
                ;;

            2)
                common_ports
                ;;

            3)
                show_rules
                read -rp "Press Enter..."
                ;;

            4)
                echo "Goodbye."
                exit 0
                ;;

            *)
                echo "Invalid option."
                sleep 1
                ;;

        esac

    done
}

check_root
check_ufw
enable_firewall
main_menu