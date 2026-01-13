#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/firewall.sh"

firewall_tui_menu() {
    while true; do
        choice=$(whiptail --clear --title "Firewall Yonetimi - TUI" \
            --menu "Bir islem secin:" 20 65 7 \
            "1" "Firewall Durumu" \
            "2" "Firewall Kurallarini Listele" \
            "3" "Port Ac (Allow)" \
            "4" "Port Kapat (Deny)" \
            "5" "Firewall Etkinlestir" \
            "6" "Firewall Devre Disi Birak" \
            "0" "Ana Menu" \
            3>&1 1>&2 2>&3)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ] || [ "$choice" = "0" ]; then
            break
        fi
        
        case "$choice" in
            1)
                output=$(check_firewall_status 2>&1)
                whiptail --title "Firewall Durumu" --scrolltext --msgbox "$output" 22 75
                ;;
            2)
                output=$(list_firewall_rules 2>&1)
                whiptail --title "Firewall Kurallari" --scrolltext --msgbox "$output" 25 80
                ;;
            3)
                port=$(whiptail --inputbox "Acilacak port numarasi:" 10 50 3>&1 1>&2 2>&3)
                if [ -n "$port" ]; then
                    protocol=$(whiptail --inputbox "Protokol (tcp/udp, varsayilan: tcp):" 10 50 "tcp" 3>&1 1>&2 2>&3)
                    protocol=${protocol:-tcp}
                    output=$(allow_port "$port" "$protocol" 2>&1)
                    whiptail --title "Port Ac" --msgbox "$output" 12 60
                fi
                ;;
            4)
                port=$(whiptail --inputbox "Kapatilacak port numarasi:" 10 50 3>&1 1>&2 2>&3)
                if [ -n "$port" ]; then
                    protocol=$(whiptail --inputbox "Protokol (tcp/udp, varsayilan: tcp):" 10 50 "tcp" 3>&1 1>&2 2>&3)
                    protocol=${protocol:-tcp}
                    output=$(deny_port "$port" "$protocol" 2>&1)
                    whiptail --title "Port Kapat" --msgbox "$output" 12 60
                fi
                ;;
            5)
                output=$(enable_firewall 2>&1)
                whiptail --title "Firewall Etkinlestir" --msgbox "$output" 10 60
                ;;
            6)
                whiptail --yesno "Firewall'u devre disi birakmak istediginize emin misiniz?" 10 60
                if [ $? -eq 0 ]; then
                    output=$(disable_firewall 2>&1)
                    whiptail --title "Firewall Devre Disi" --msgbox "$output" 10 60
                fi
                ;;
            *)
                whiptail --msgbox "Gecersiz secim!" 8 40
                ;;
        esac
    done
}
