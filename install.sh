#!/bin/bash

# Sistem Yonetim Araci - Kurulum Scripti
# PARDUS Linux uyumlu

echo "    Sistem Yonetim Araci - Kurulum                       "
echo "═════════════════════════════════════════════════════════"
echo ""

# Root kontrolu
if (( $EUID != 0 )); then
    echo "HATA: Bu script root yetkisi ile calistirilmalidir."
    echo "Kullanim: sudo ./install.sh"
    exit 1
fi 

# Gerekli paketler
REQUIRED_PACKAGES=("yad" "whiptail" "systemd" "cron" "ufw")
MISSING_PACKAGES=()

echo "Paket kontrolu yapiliyor..."

# Eksik paketleri tespit et
for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! command -v "$package" &> /dev/null && ! dpkg -l | grep -q "^ii  $package"; then
        MISSING_PACKAGES+=("$package")
    fi
done

# Eksik paket varsa
if (( ${#MISSING_PACKAGES[@]} != 0 )); then
    echo ""
    echo "Eksik paketler tespit edildi: ${MISSING_PACKAGES[@]}"
    echo ""
    
    read -p "Eksik paketler yuklensin mi? (e/h): " SECIM
    
    case "$SECIM" in
        e|E|y|Y)
            echo ""
            echo " Paketler yukleniyor..."
            apt-get update
            apt-get install -y "${MISSING_PACKAGES[@]}"
            
            if [ $? -eq 0 ]; then
                echo " Paketler basariyla yuklendi!"
            else
                echo " Paket yukleme basarisiz!"
                exit 1
            fi
            ;;
        *)
            echo "Paket yuklemesi iptal edildi. Program askiya aliniyor."
            exit 1
            ;;
    esac
else
    echo "Tum gerekli paketler mevcut!"
fi

echo ""
echo "Calistirma izinleri veriliyor..."

# Calistirma izinleri
chmod +x sysmonitor.sh 2>/dev/null
chmod +x src/gui/*.sh 2>/dev/null
chmod +x src/tui/*.sh 2>/dev/null
chmod +x src/core/*.sh 2>/dev/null

echo "Izinler ayarlandi!"

echo ""
echo "      Kurulum Basariyla Tamamlandi"
echo ""
echo "Kullanim:"
echo "  GUI icin: ./sysmonitor.sh --gui"
echo "  TUI icin: ./sysmonitor.sh --tui"
echo "  Yardim:   ./sysmonitor.sh --help"
echo ""





