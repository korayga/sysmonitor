#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/cron.sh"

cron_tui_menu() {
    while true; do
        choice=$(whiptail --clear --title "Cron Yonetimi - TUI" \
            --menu "Bir islem secin:" 22 65 7 \
            "1" "Cron Gorevlerini Listele" \
            "2" "Yeni Cron Gorevi Ekle" \
            "3" "Cron Gorevi Sil" \
            "4" "Tum Cron Gorevlerini Sil" \
            "5" "Cron Servis Durumu" \
            "6" "Cron Loglari" \
            "0" "Ana Menu" \
            3>&1 1>&2 2>&3)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ] || [ "$choice" = "0" ]; then
            break
        fi
        
        case "$choice" in
            1)
                output=$(list_cron_jobs)
                whiptail --title "Cron Gorevleri" --scrolltext --msgbox "$output" 25 75
                ;;
            2)
                schedule=$(whiptail --inputbox "Schedule formati (orn: 0 2 * * *):" 10 60 3>&1 1>&2 2>&3)
                if [ -n "$schedule" ]; then
                    command=$(whiptail --inputbox "Calistirilacak komut:" 10 60 3>&1 1>&2 2>&3)
                    if [ -n "$command" ]; then
                        output=$(add_cron_job "$schedule" "$command" 2>&1)
                        whiptail --title "Cron Ekleme Sonucu" --msgbox "$output" 15 60
                    fi
                fi
                ;;
            3)
                line_number=$(whiptail --inputbox "Silinecek gorev numarasi:" 10 60 3>&1 1>&2 2>&3)
                if [ -n "$line_number" ]; then
                    output=$(echo "e" | remove_cron_by_number "$line_number" 2>&1)
                    whiptail --title "Cron Silme Sonucu" --msgbox "$output" 15 60
                fi
                ;;
            4)
                whiptail --yesno "TUM cron gorevlerini silmek istediginize emin misiniz?" 10 60
                if [ $? -eq 0 ]; then
                    output=$(echo "EVET" | remove_all_cron 2>&1)
                    whiptail --title "Tumunu Sil" --msgbox "$output" 15 60
                fi
                ;;
            5)
                output=$(check_cron_service 2>&1)
                whiptail --title "Cron Servis Durumu" --scrolltext --msgbox "$output" 25 75
                ;;
            6)
                output=$(show_cron_logs 50 2>&1)
                whiptail --title "Cron Loglari" --scrolltext --msgbox "$output" 25 80
                ;;
            *)
                whiptail --msgbox "Gecersiz secim!" 8 40
                ;;
        esac
    done
}
