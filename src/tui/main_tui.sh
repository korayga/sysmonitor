#!/bin/bash

# TUI Ana Menü (whiptail kullanarak)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/utils.sh"
source "$SCRIPT_DIR/monitor_tui.sh"
source "$SCRIPT_DIR/service_tui.sh"
source "$SCRIPT_DIR/logs_tui.sh"
source "$SCRIPT_DIR/firewall_tui.sh"
source "$SCRIPT_DIR/cron_tui.sh"

# whiptail kontrolu
if ! command -v whiptail &> /dev/null; then
    echo "Hata: whiptail yuklu degil!"
    echo "Kurulum: sudo apt-get install whiptail"
    exit 1
fi

show_main_menu() {
    while true; do
        choice=$(whiptail --clear --title "Sistem Yonetim Araci - TUI" \
            --menu "Bir secenek secin:" 20 60 7 \
            "1" "Sistem Monitor" \
            "2" "Servis Yonetimi" \
            "3" "Log Yonetimi" \
            "4" "Cron Yonetimi" \
            "5" "Firewall Yonetimi" \
            "0" "Cikis" \
            3>&1 1>&2 2>&3)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ]; then
            break
        fi
        
        case "$choice" in
            1)
                monitor_tui_menu
                ;;
            2)
                service_tui_menu
                ;;
            3)
                logs_tui_menu
                ;;
            4)  cron_tui_menu
                ;;
            5)
                firewall_tui_menu
                ;;
            0)
                clear
                exit 0
                ;;
            *)
                whiptail --msgbox "Gecersiz secim!" 8 40
                ;;
        esac
    done
    clear
}

# Script direkt çalıştırılırsa
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_main_menu
fi
