#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/monitor.sh"

monitor_tui_menu() {
    while true; do
        choice=$(whiptail --clear --title "Sistem Monitor - TUI" \
            --menu "Bir islem secin:" 24 65 9 \
            "1" "Sistem Ozeti" \
            "2" "CPU Kullanimi" \
            "3" "RAM Kullanimi Detayli" \
            "4" "Disk Kullanimi" \
            "5" "Top CPU Surecler" \
            "6" "Kaynak Uyarilari" \
            "7" "Zombie Surec Ara" \
            "8" "Zombie Surec Oldurmek" \
            "0" "Ana Menu" \
            3>&1 1>&2 2>&3)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ] || [ "$choice" = "0" ]; then
            break
        fi
        
        case "$choice" in
            1)
                output=$(get_system_summary)
                whiptail --title "Sistem Ozeti" --scrolltext --msgbox "$output" 25 75
                ;;
            2)
                output=$(get_cpu_usage)
                whiptail --title "CPU Kullanimi" --scrolltext --msgbox "$output" 20 75
                ;;
            3)
                output=$(get_ram_detailed)
                whiptail --title "RAM Kullanimi" --msgbox "$output" 20 60
                ;;
            4)
                output=$(get_disk_usage)
                whiptail --title "Disk Kullanimi" --msgbox "$output" 15 60
                ;;
            5)
                output=$(get_top_cpu_processes)
                whiptail --title "En Yuksek CPU Kullanan Surecler" --scrolltext --msgbox "$output" 22 80
                ;;
            6)
                output=$(check_resource_warnings)
                whiptail --title "Kaynak Uyarilari" --msgbox "$output" 15 60
                ;;
            7)
                output=$(find_zombie_processes)
                whiptail --title "Zombie Surecler" --msgbox "$output" 15 60
                ;;
            8)
                zombie_pid=$(whiptail --inputbox "Zombie surec PID'sini girin:" 10 60 3>&1 1>&2 2>&3)
                if [ -n "$zombie_pid" ]; then
                    output=$(echo "e" | kill_zombie_process "$zombie_pid" 2>&1)
                    whiptail --title "Zombie Surec Temizleme" --scrolltext --msgbox "$output" 22 75
                fi
                ;;
            *)
                whiptail --msgbox "Gecersiz secim!" 8 40
                ;;
        esac
    done
}
