#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/services.sh"

service_tui_menu() {
    while true; do
        choice=$(whiptail --clear --title "Servis Yonetimi - TUI" \
            --menu "Bir islem secin:" 22 65 9 \
            "1" "Tum Servisleri Listele" \
            "2" "Calisan Servisleri Listele" \
            "3" "Basarisiz Servisleri Listele" \
            "4" "Servis Durumunu Goruntule" \
            "5" "Servis Baslat" \
            "6" "Servis Durdur" \
            "7" "Servis Yeniden Baslat" \
            "8" "Servis Istatistikleri" \
            "0" "Ana Menu" \
            3>&1 1>&2 2>&3)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ] || [ "$choice" = "0" ]; then
            break
        fi
        
        case "$choice" in
            1)
                output=$(list_services all)
                whiptail --title "Tum Servisler" --scrolltext --msgbox "$output" 25 75
                ;;
            2)
                output=$(list_services running)
                whiptail --title "Calisan Servisler" --scrolltext --msgbox "$output" 25 75
                ;;
            3)
                output=$(list_services failed)
                whiptail --title "Basarisiz Servisler" --scrolltext --msgbox "$output" 25 75
                ;;
            4)
                service_name=$(whiptail --inputbox "Servis adi:" 10 60 3>&1 1>&2 2>&3)
                if [ -n "$service_name" ]; then
                    output=$(get_service_info "$service_name")
                    whiptail --title "Servis Durumu: $service_name" --scrolltext --msgbox "$output" 22 75
                fi
                ;;
            5)
                service_name=$(whiptail --inputbox "Baslatilacak servis adi:" 10 60 3>&1 1>&2 2>&3)
                if [ -n "$service_name" ]; then
                    output=$(start_service "$service_name" 2>&1)
                    whiptail --title "Servis Baslat" --msgbox "$output" 10 60
                fi
                ;;
            6)
                service_name=$(whiptail --inputbox "Durdurulacak servis adi:" 10 60 3>&1 1>&2 2>&3)
                if [ -n "$service_name" ]; then
                    output=$(stop_service "$service_name" 2>&1)
                    whiptail --title "Servis Durdur" --msgbox "$output" 10 60
                fi
                ;;
            7)
                service_name=$(whiptail --inputbox "Yeniden baslatilacak servis adi:" 10 60 3>&1 1>&2 2>&3)
                if [ -n "$service_name" ]; then
                    output=$(restart_service "$service_name" 2>&1)
                    whiptail --title "Servis Yeniden Baslat" --msgbox "$output" 10 60
                fi
                ;;
            8)
                output=$(count_services)
                whiptail --title "Servis Istatistikleri" --msgbox "$output" 12 60
                ;;
            *)
                whiptail --msgbox "Gecersiz secim!" 8 40
                ;;
        esac
    done
}
