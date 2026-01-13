#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/monitor.sh"

monitor_gui_menu() {
    while true; do
        choice=$(yad --list \
            --title="Sistem Monitor" \
            --width=600 --height=500 \
            --column="Secenek" --column="Islem" \
            --text="<b>Sistem Monitor</b>\nBir islem secin:" \
            --button="Geri:1" --button="Tamam:0" \
            "1" "Sistem Ozeti" \
            "2" "CPU Kullanimi" \
            "3" "RAM Kullanimi Detayli" \
            "4" "Disk Kullanimi" \
            "5" "Top CPU Surecler" \
            "6" "Kaynak Uyarilari Kontrol" \
            "7" "Zombie Surec Ara" \
            "8" "Zombie Surec Oldurmek" 2>/dev/null)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ]; then
            break
        fi
        
        choice=$(echo "$choice" | cut -d'|' -f1)
        
        case "$choice" in
            1)
                output=$(get_system_summary)
                yad --text-info --title="Sistem Ozeti" \
                    --width=700 --height=500 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            2)
                output=$(get_cpu_usage)
                yad --text-info --title="CPU Kullanimi" \
                    --width=700 --height=400 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            3)
                output=$(get_ram_detailed)
                yad --text-info --title="RAM Kullanimi" \
                    --width=600 --height=400 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            4)
                output=$(get_disk_usage)
                yad --text-info --title="Disk Kullanimi" \
                    --width=600 --height=400 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            5)
                output=$(get_top_cpu_processes)
                yad --text-info --title="En Yuksek CPU Kullanan Surecler" \
                    --width=800 --height=500 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            6)
                output=$(check_resource_warnings)
                yad --text-info --title="Kaynak Uyarilari" \
                    --width=600 --height=400 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            7)
                output=$(find_zombie_processes)
                yad --text-info --title="Zombie Surecler" \
                    --width=600 --height=400 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            8)
                zombie_pid=$(yad --entry \
                    --title="Zombie Surec Oldurmek" \
                    --text="Zombie surec PID'sini girin:" \
                    --width=400 2>/dev/null)
                if [ -n "$zombie_pid" ]; then
                    output=$(echo "e" | kill_zombie_process "$zombie_pid" 2>&1)
                    yad --text-info --title="Zombie Surec Temizleme" \
                        --width=600 --height=400 \
                        --button="Tamam:0" <<< "$output" 2>/dev/null
                fi
                ;;
        esac
    done
}
