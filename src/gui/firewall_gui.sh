#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/firewall.sh"

firewall_gui_menu() {
    while true; do
        choice=$(yad --list \
            --title="Firewall Yonetimi" \
            --width=600 --height=450 \
            --column="Secenek" --column="Islem" \
            --text="<b>Firewall Yonetimi</b>\nBir islem secin:" \
            --button="Geri:1" --button="Tamam:0" \
            "1" "Firewall Durumu" \
            "2" "Firewall Kurallarini Listele" \
            "3" "Port Ac (Allow)" \
            "4" "Port Kapat (Deny)" \
            "5" "Firewall Etkinlestir" \
            "6" "Firewall Devre Disi Birak" 2>/dev/null)
        
        exit_status=$?
        
        if [ $exit_status -ne 0 ]; then
            break
        fi
        
        choice=$(echo "$choice" | cut -d'|' -f1)
        
        case "$choice" in
            1)
                output=$(check_firewall_status 2>&1)
                yad --text-info --title="Firewall Durumu" \
                    --width=700 --height=500 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            2)
                output=$(list_firewall_rules 2>&1)
                yad --text-info --title="Firewall Kurallari" \
                    --width=900 --height=600 \
                    --button="Tamam:0" <<< "$output" 2>/dev/null
                ;;
            3)
                result=$(yad --form \
                    --title="Port Ac" \
                    --width=400 \
                    --field="Port numarasi:" \
                    --field="Protokol (tcp/udp):":CB \
                    "" "tcp!udp" 2>/dev/null)
                
                if [ -n "$result" ]; then
                    port=$(echo "$result" | cut -d'|' -f1)
                    protocol=$(echo "$result" | cut -d'|' -f2)
                    protocol=${protocol:-tcp}
                    
                    if [ -n "$port" ]; then
                        output=$(allow_port "$port" "$protocol" 2>&1)
                        yad --info --title="Port Ac" \
                            --text="$output" \
                            --width=500 2>/dev/null
                    fi
                fi
                ;;
            4)
                result=$(yad --form \
                    --title="Port Kapat" \
                    --width=400 \
                    --field="Port numarasi:" \
                    --field="Protokol (tcp/udp):":CB \
                    "" "tcp!udp" 2>/dev/null)
                
                if [ -n "$result" ]; then
                    port=$(echo "$result" | cut -d'|' -f1)
                    protocol=$(echo "$result" | cut -d'|' -f2)
                    protocol=${protocol:-tcp}
                    
                    if [ -n "$port" ]; then
                        output=$(deny_port "$port" "$protocol" 2>&1)
                        yad --info --title="Port Kapat" \
                            --text="$output" \
                            --width=500 2>/dev/null
                    fi
                fi
                ;;
            5)
                output=$(enable_firewall 2>&1)
                yad --info --title="Firewall Etkinlestir" \
                    --text="$output" \
                    --width=500 2>/dev/null
                ;;
            6)
                yad --question \
                    --title="Onay" \
                    --text="Firewall'u devre disi birakmak istediginize emin misiniz?" \
                    --width=400 2>/dev/null
                if [ $? -eq 0 ]; then
                    output=$(disable_firewall 2>&1)
                    yad --info --title="Firewall Devre Disi" \
                        --text="$output" \
                        --width=400 2>/dev/null
                fi
                ;;
        esac
    done
}
