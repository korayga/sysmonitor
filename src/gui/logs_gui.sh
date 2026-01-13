#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/logs.sh"

logs_gui_menu() {
    while true; do
        choice=$(yad --list \
            --title="Log Yonetimi" \
            --width=600 --height=500 \
            --column="Secenek" --column="Islem" \
            --text="<b>Log Yonetimi</b>\nBir islem secin:" \
            --button="Geri:1" --button="Tamam:0" \
            "1" "Son 100 Log Satiri" \
            "2" "Bugunku Loglari" \
            "3" "Son 1 Saatin Loglari" \
            "4" "Hata Loglari" \
            "5" "Uyari Loglari" \
            "6" "Log Istatistikleri" \
            "7" "Log Ara" \
            "8" "Basarisiz Login Girisimleri" 2>/dev/null)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ]; then
            break
        fi
        
        choice=$(echo "$choice" | cut -d'|' -f1)
        
        case "$choice" in
            1)
                output=$(show_logs 100 2>&1)
                yad --text-info --title="Son 100 Log" \
                    --width=900 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            2)
                output=$(show_today_logs 2>&1)
                yad --text-info --title="Bugunku Loglari" \
                    --width=900 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            3)
                output=$(show_last_hour_logs 2>&1)
                yad --text-info --title="Son 1 Saat" \
                    --width=900 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            4)
                lines=$(yad --entry \
                    --title="Hata Loglari" \
                    --text="Kac satir? (varsayilan: 100)" \
                    --entry-text="100" \
                    --width=400 2>/dev/null)
                lines=${lines:-100}
                output=$(show_error_logs "$lines" 2>&1)
                yad --text-info --title="Hata Loglari" \
                    --width=900 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            5)
                lines=$(yad --entry \
                    --title="Uyari Loglari" \
                    --text="Kac satir? (varsayilan: 100)" \
                    --entry-text="100" \
                    --width=400 2>/dev/null)
                lines=${lines:-100}
                output=$(show_warning_logs "$lines" 2>&1)
                yad --text-info --title="Uyari Loglari" \
                    --width=900 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            6)
                output=$(log_statistics 2>&1)
                yad --text-info --title="Log Istatistikleri" \
                    --width=700 --height=500 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            7)
                keyword=$(yad --entry \
                    --title="Log Ara" \
                    --text="Aranacak kelimeyi girin:" \
                    --width=400 2>/dev/null)
                if [ -n "$keyword" ]; then
                    lines=$(yad --entry \
                        --title="Satir Sayisi" \
                        --text="Kac satir? (varsayilan: 50)" \
                        --entry-text="50" \
                        --width=400 2>/dev/null)
                    lines=${lines:-50}
                    output=$(search_log "$keyword" "$lines" 2>&1)
                    yad --text-info --title="Arama Sonuclari: $keyword" \
                        --width=900 --height=600 \
                        --button="Tamam:0" <<< "$output" 2>/dev/null
                fi
                ;;
            8)
                output=$(show_failed_logins 20 2>&1)
                yad --text-info --title="Basarisiz Login Girisimleri" \
                    --width=900 --height=500 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
        esac
    done
}
