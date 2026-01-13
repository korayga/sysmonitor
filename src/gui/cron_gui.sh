#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/cron.sh"

cron_gui_menu() {
    while true; do
        choice=$(yad --list \
            --title="Cron Yonetimi" \
            --width=600 --height=450 \
            --column="Secenek" --column="Islem" \
            --text="<b>Cron Yonetimi</b>\nBir islem secin:" \
            --button="Geri:1" --button="Tamam:0" \
            "1" "Cron Gorevlerini Listele" \
            "2" "Yeni Cron Gorevi Ekle" \
            "3" "Cron Gorevi Sil" \
            "4" "Tum Cron Gorevlerini Sil" \
            "5" "Cron Servis Durumu" \
            "6" "Cron Loglari" 2>/dev/null)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ]; then
            break
        fi
        
        choice=$(echo "$choice" | cut -d'|' -f1)
        
        case "$choice" in
            1)
                output=$(list_cron_jobs)
                yad --text-info --title="Cron Gorevleri" \
                    --width=800 --height=500 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            2)
                result=$(yad --form \
                    --title="Yeni Cron Gorevi Ekle" \
                    --width=500 \
                    --field="Schedule formati (orn: 0 2 * * *):" \
                    --field="Calistirilacak komut:" 2>/dev/null)
                
                if [ -n "$result" ]; then
                    schedule=$(echo "$result" | cut -d'|' -f1)
                    command=$(echo "$result" | cut -d'|' -f2)
                    
                    if [ -n "$schedule" ] && [ -n "$command" ]; then
                        output=$(add_cron_job "$schedule" "$command" 2>&1)
                        yad --info --title="Cron Ekleme Sonucu" \
                            --text="$output" \
                            --width=500 2>/dev/null
                    fi
                fi
                ;;
            3)
                line_number=$(yad --entry \
                    --title="Cron Gorevi Sil" \
                    --text="Silinecek gorev numarasi:" \
                    --width=400 2>/dev/null)
                if [ -n "$line_number" ]; then
                    output=$(echo "e" | remove_cron_by_number "$line_number" 2>&1)
                    yad --info --title="Cron Silme Sonucu" \
                        --text="$output" \
                        --width=500 2>/dev/null
                fi
                ;;
            4)
                yad --question \
                    --title="Onay" \
                    --text="TUM cron gorevlerini silmek istediginize emin misiniz?" \
                    --width=400 2>/dev/null
                if [ $? -eq 0 ]; then
                    output=$(echo "EVET" | remove_all_cron 2>&1)
                    yad --info --title="Tumunu Sil" \
                        --text="$output" \
                        --width=400 2>/dev/null
                fi
                ;;
            5)
                output=$(check_cron_service 2>&1)
                yad --text-info --title="Cron Servis Durumu" \
                    --width=700 --height=500 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            6)
                output=$(show_cron_logs 50 2>&1)
                yad --text-info --title="Cron Loglari" \
                    --width=900 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
        esac
    done
}
