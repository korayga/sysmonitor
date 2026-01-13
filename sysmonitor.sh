#!/bin/bash

# Sistem Yonetim Araci - Ana Script
# PARDUS Linux uyumlu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    cat << EOF
            Sistem Yonetim Araci - Yardim                     
══════════════════════════════════════════════════════════

Kullanim: $0 [SECENEK]

SECENEKLER:
  --gui, -g        GUI modunda baslat 
  --tui, -t        TUI modunda baslat 
  --help, -h       Yardim mesajini goster

ORNEKLER:
  $0 --gui         # GUI modunda baslat
  $0 --tui         # TUI modunda baslat
  $0 -h            # Yardim mesajini goster

GEREKSINIMLER:
  GUI icin: yad
  TUI icin: whiptail
  
Kurulum:
  sudo apt-get install yad whiptail

EOF
}

start_gui() {
    if ! command -v yad &> /dev/null; then
        echo "HATA: YAD yuklu degil!"
        echo "Kurulum: sudo apt-get install yad"
        exit 1
    fi
    
    echo "GUI modu baslatiliyor..."
    source "$SCRIPT_DIR/src/gui/main_gui.sh"
    show_main_gui_menu
}

start_tui() {
    if ! command -v whiptail &> /dev/null; then
        echo "HATA: whiptail yuklu degil!"
        echo "Kurulum: sudo apt-get install whiptail"
        exit 1
    fi
    
    source "$SCRIPT_DIR/src/tui/main_tui.sh"
    show_main_menu
}

# Argüman kontrolü
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    --gui|-g)
        start_gui
        ;;
    --tui|-t)
        start_tui
        ;;
    --help|-h)
        show_help
        ;;
    *)
        echo "Hata: Gecersiz secenek '$1'"
        echo "Kullanim: $0 --help"
        exit 1
        ;;
esac
