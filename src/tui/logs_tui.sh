#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/logs.sh"

logs_tui_menu() {
    while true; do
        choice=$(whiptail --clear --title "Log Yonetimi - TUI" \
            --menu "Bir islem secin:" 24 65 10 \
            "1" "Son 100 Log Satiri" \
            "2" "Bugunku Loglari" \
            "3" "Son 1 Saatin Loglari" \
            "4" "Hata Loglari" \
            "5" "Uyari Loglari" \
            "6" "Canli Log Izle" \
            "7" "Log Istatistikleri" \
            "8" "Log Ara" \
            "9" "Basarisiz Login Girisimleri" \
            "0" "Ana Menu" \
            3>&1 1>&2 2>&3)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ] || [ "$choice" = "0" ]; then
            break
        fi
        
        case "$choice" in
            1)
                output=$(show_logs 100 2>&1)
                whiptail --title "Son 100 Log" --scrolltext --msgbox "$output" 25 85
                ;;
            2)
                output=$(show_today_logs 2>&1)
                whiptail --title "Bugünün Loglari" --scrolltext --msgbox "$output" 25 85
                ;;
            3)
                output=$(show_last_hour_logs 2>&1)
                whiptail --title "Son 1 Saat" --scrolltext --msgbox "$output" 25 85
                ;;
            4)
                lines=$(whiptail --inputbox "Kaç satir? (varsayilan: 100)" 10 50 "100" 3>&1 1>&2 2>&3)
                lines=${lines:-100}
                output=$(show_error_logs "$lines" 2>&1)
                whiptail --title "Hata Loglari" --scrolltext --msgbox "$output" 25 85
                ;;
            5)
                lines=$(whiptail --inputbox "Kaç satir? (varsayilan: 100)" 10 50 "100" 3>&1 1>&2 2>&3)
                lines=${lines:-100}
                output=$(show_warning_logs "$lines" 2>&1)
                whiptail --title "Uyari Loglari" --scrolltext --msgbox "$output" 25 85
                ;;
            6)
                whiptail --msgbox "Canli log izleme baslatiliyor (CTRL+C ile cikis)..." 8 60
                clear
                follow_logs
                ;;
            7)
                output=$(log_statistics 2>&1)
                whiptail --title "Log İstatistikleri" --scrolltext --msgbox "$output" 22 75
                ;;
            8)
                keyword=$(whiptail --inputbox "Aranacak kelime:" 10 50 3>&1 1>&2 2>&3)
                if [ -n "$keyword" ]; then
                    lines=$(whiptail --inputbox "Kaç satir? (varsayilan: 50)" 10 50 "50" 3>&1 1>&2 2>&3)
                    lines=${lines:-50}
                    output=$(search_log "$keyword" "$lines" 2>&1)
                    whiptail --title "Arama Sonuçlari: $keyword" --scrolltext --msgbox "$output" 25 85
                fi
                ;;
            9)
                output=$(show_failed_logins 20 2>&1)
                whiptail --title "Basarisiz Login Girisimleri" --scrolltext --msgbox "$output" 25 80
                ;;
            *)
                whiptail --msgbox "Geçersiz seçim!" 8 40
                ;;
        esac
    done
}
