#!/bin/bash

# GUI Ana Menü (YAD kullanarak)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/utils.sh"
source "$SCRIPT_DIR/monitor_gui.sh"
source "$SCRIPT_DIR/service_gui.sh"
source "$SCRIPT_DIR/logs_gui.sh"
source "$SCRIPT_DIR/cron_gui.sh"
source "$SCRIPT_DIR/firewall_gui.sh"


# YAD kontrolu
if ! command -v yad &> /dev/null; then
    echo "Hata: YAD yuklu degil!"
    echo "Kurulum: sudo apt-get install yad"
    exit 1
fi

show_main_gui_menu() {
    while true; do
        choice=$(yad --list \
            --title="Sistem Yonetim Araci" \
            --width=500 --height=400 \
            --column="Secenek" --column="Aciklama" \
            --text="<b>Sistem Yonetim Araci</b>\nBir secenek secin:" \
            --button="Cikis:1" --button="Tamam:0" \
            "1" "Sistem Monitor" \
            "2" "Servis Yonetimi" \
            "3" "Log Yonetimi" \
            "4" "Cron Yonetimi" \
            "5" "Firewall Yonetimi" 2>/dev/null)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ]; then
            break
        fi
        
        choice=$(echo "$choice" | cut -d'|' -f1)
        
        case "$choice" in
            1)
                monitor_gui_menu
                ;;
            2)
                service_gui_menu
                ;;
            3)
                logs_gui_menu
                ;;
            4)
                cron_gui_menu
                ;;
            5)
                firewall_gui_menu
                ;;
        esac
    done
}

# Script direkt çalıştırılırsa
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_main_gui_menu
fi
