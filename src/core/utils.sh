#!/bin/bash

require_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Bu islem icin root yetkileri gerekli!"
        echo "Kullanim: sudo $0"
        exit 1
    fi
}

# Kullanim: ask_yes_no "Devam etmek istiyor musunuz?"
ask_yes_no() {
    local question="$1"
    local answer
    
    while true; do
        echo -e "$question (y/n): "
        read -r answer
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        case "$answer" in
            e|evet|y|yes)
                return 0
                ;;
            h|hayir|n|no)
                return 1
                ;;
            *)
                echo  "Lutfen 'y' veya 'n' girin!"
                ;;
        esac
    done
}