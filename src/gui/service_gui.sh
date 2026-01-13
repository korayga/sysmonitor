#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/services.sh"

service_gui_menu() {
    while true; do
        choice=$(yad --list \
            --title="Servis Yonetimi" \
            --width=600 --height=500 \
            --column="Secenek" --column="Islem" \
            --text="<b>Servis Yonetimi</b>\nBir islem secin:" \
            --button="Geri:1" --button="Tamam:0" \
            "1" "Tum Servisleri Listele" \
            "2" "Calisan Servisleri Listele" \
            "3" "Basarisiz Servisleri Listele" \
            "4" "Servis Durumu Goruntule" \
            "5" "Servis Baslat" \
            "6" "Servis Durdur" \
            "7" "Servis Yeniden Baslat" \
            "8" "Servis Istatistikleri" 2>/dev/null)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ]; then
            break
        fi
        
        choice=$(echo "$choice" | cut -d'|' -f1)
        
        case "$choice" in
            1)
                output=$(list_services all)
                yad --text-info --title="Tum Servisler" \
                    --width=700 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            2)
                output=$(list_services running)
                yad --text-info --title="Calisan Servisler" \
                    --width=700 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            3)
                output=$(list_services failed)
                yad --text-info --title="Basarisiz Servisler" \
                    --width=700 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            4)
                service_name=$(yad --entry \
                    --title="Servis Durumu" \
                    --text="Servis adini girin:" \
                    --width=400 2>/dev/null)
                if [ -n "$service_name" ]; then
                    output=$(get_service_info "$service_name")
                    yad --text-info --title="Servis Durumu: $service_name" \
                        --width=700 --height=500 \
                        --button="Tamam:0" <<< "$output" 2>/dev/null
                fi
                ;;
            5)
                service_name=$(yad --entry \
                    --title="Servis Baslat" \
                    --text="Baslatilacak servis adini girin:" \
                    --width=400 2>/dev/null)
                if [ -n "$service_name" ]; then
                    output=$(start_service "$service_name" 2>&1)
                    yad --info --title="Servis Baslat" \
                        --text="$output" \
                        --width=400 2>/dev/null
                fi
                ;;
            6)
                service_name=$(yad --entry \
                    --title="Servis Durdur" \
                    --text="Durdurulacak servis adini girin:" \
                    --width=400 2>/dev/null)
                if [ -n "$service_name" ]; then
                    output=$(stop_service "$service_name" 2>&1)
                    yad --info --title="Servis Durdur" \
                        --text="$output" \
                        --width=400 2>/dev/null
                fi
                ;;
            7)
                service_name=$(yad --entry \
                    --title="Servis Yeniden Baslat" \
                    --text="Yeniden baslatilacak servis adini girin:" \
                    --width=400 2>/dev/null)
                if [ -n "$service_name" ]; then
                    output=$(restart_service "$service_name" 2>&1)
                    yad --info --title="Servis Yeniden Baslat" \
                        --text="$output" \
                        --width=400 2>/dev/null
                fi
                ;;
            8)
                output=$(count_services)
                yad --info --title="Servis Istatistikleri" \
                    --text="$output" \
                    --width=500 2>/dev/null
                ;;
        esac
    done
}
