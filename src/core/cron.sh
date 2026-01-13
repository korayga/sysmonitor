#!/bin/bash

# crontab -l    # List 
# crontab -e    # Edit
# crontab -r    # Remove 

#   * * * * * komut HER DAKİKA
#   0 * * * * komut HER SAAT
#   0 0 * * * komut HER GÜN


list_cron_jobs(){
    echo "      Mevcut Cron Gorevleri"
    echo ""

    if ! crontab -l &>/dev/null
    then
        echo "listelencek crontab yok"
        return 0
    fi
    
    crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$"

}

parse_cron_schedule() {
    local schedule="$1"
    
    local minute=$(echo "$schedule" | awk '{print $1}')
    local hour=$(echo "$schedule" | awk '{print $2}')
    local day=$(echo "$schedule" | awk '{print $3}')
    local month=$(echo "$schedule" | awk '{print $4}')
    local weekday=$(echo "$schedule" | awk '{print $5}')
    
    local description=""
    
    # Ozel ifadeler
    case "$schedule" in
        "@reboot")
            echo "Sistem baslangicinda"
            return
            ;;
        "@yearly"|"@annually")
            echo "Yilda bir (1 Ocak 00:00)"
            return
            ;;
        "@monthly")
            echo "Ayda bir (1. gun 00:00)"
            return
            ;;
        "@weekly")
            echo "Haftada bir (Pazar 00:00)"
            return
            ;;
        "@daily"|"@midnight")
            echo "Gunde bir (00:00)"
            return
            ;;
        "@hourly")
            echo "Saatte bir"
            return
            ;;
    esac
    
    # Dakika
    if [ "$minute" = "*" ]; then
        description="Her dakika"
    elif [[ "$minute" =~ ^[0-9]+$ ]]; then
        description="Dakika $minute"
    elif [[ "$minute" =~ ^*/([0-9]+)$ ]]; then
        description="Her ${BASH_REMATCH[1]} dakikada"
    else
        description="Dakika $minute"
    fi
    
    # Saat
    if [ "$hour" = "*" ]; then
        description="$description, her saat"
    elif [[ "$hour" =~ ^[0-9]+$ ]]; then
        description="$description, saat $hour:00"
    elif [[ "$hour" =~ ^*/([0-9]+)$ ]]; then
        description="$description, her ${BASH_REMATCH[1]} saatte"
    fi
    
    # Gün
    if [ "$day" != "*" ]; then
        description="$description, ayin $day. günü"
    fi
    
    # Ay
    if [ "$month" != "*" ]; then
        description="$description, ay $month"
    fi
    
    # Hafta gunu
    if [ "$weekday" != "*" ]; then
        case "$weekday" in
            0|7) description="$description, Pazar" ;;
            1) description="$description, Pazartesi" ;;
            2) description="$description, Sali" ;;
            3) description="$description, Carsamba" ;;
            4) description="$description, Persembe" ;;
            5) description="$description, Cuma" ;;
            6) description="$description, Cumartesi" ;;
        esac
    fi
    
    echo "$description"
}

add_cron_job() {
    local schedule="$1"
    local command="$2"
    
    if [ -z "$schedule" ] || [ -z "$command" ]; then
        echo "Hata: Schedule veya komut belirtilmedi!"
        echo "Kullanim: add_cron_job '<schedule>' '<komut>'"
        echo "Ornek: add_cron_job '0 2 * * *' '/usr/bin/backup.sh'"
        return 1
    fi
    
    # Schedule'in gecerli olup olmadigini kontrol et
    if ! validate_cron_schedule "$schedule"; then
        echo "Hata: Gecersiz cron schedule formati!"
        echo "Format: minute hour day month weekday"
        echo "Ornek: 0 2 * * * (Her gun saat 02:00)"
        return 1
    fi
    
    # Yeni görev satırı
    local new_job="$schedule $command"
    
    # Ayni gorev var mi kontrol et
    if crontab -l 2>/dev/null | grep -qF "$command"; then
        echo "Uyari: Bu komut zaten crontab'da mevcut!"
        echo "Mevcut: $(crontab -l 2>/dev/null | grep -F "$command")"
        read -p "Yine de eklemek istiyor musunuz? (e/h): " answer
        if [ "$answer" != "e" ]; then
            echo "Iptal edildi."
            return 0
        fi
    fi
    
    # Mevcut crontab'i al ve yeni gorevi ekle
    (crontab -l 2>/dev/null; echo "$new_job") | crontab -
    
    if [ $? -eq 0 ]; then
        echo "Cron gorevi basariyla eklendi:"
        echo "  Schedule: $schedule"
        echo "  Komut: $command"
        echo "  Aciklama: $(parse_cron_schedule "$schedule")"
    else
        echo "Cron gorevi eklenemedi!"
        return 1
    fi
}
validate_cron_schedule() {
    local schedule="$1"
    
    # Ozel ifadeler
    if [[ "$schedule" =~ ^@(reboot|yearly|annually|monthly|weekly|daily|midnight|hourly)$ ]]; then
        return 0
    fi
    
    # Normal cron format 
    local fields=$(echo "$schedule" | wc -w)
    if [ "$fields" -ne 5 ]; then
        return 1
    fi
    
    # Basit validasyon (daha detaylı olabilir)
    if [[ "$schedule" =~ ^[0-9\*\,\-\/]+[[:space:]]+[0-9\*\,\-\/]+[[:space:]]+[0-9\*\,\-\/]+[[:space:]]+[0-9\*\,\-\/]+[[:space:]]+[0-9\*\,\-\/]+$ ]]; then
        return 0
    fi
    
    return 1
}
remove_cron_by_number() {
    local line_number="$1"
    
    if [ -z "$line_number" ]; then
        echo "Hata: Satir numarasi belirtilmedi!"
        echo "Kullanim: remove_cron_by_number <numara>"
        return 1
    fi
    
    if ! crontab -l &>/dev/null; then
        echo "Cron gorevi bulunamadi."
        return 1
    fi
    
    # Secilen gorevi goster
    local selected_job=$(crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | sed -n "${line_number}p")
    
    if [ -z "$selected_job" ]; then
        echo "Hata: $line_number numarali gorev bulunamadi!"
        return 1
    fi
    
    echo "Silinecek gorev:"
    echo "  $selected_job"
    echo ""
    read -p "Silmek istediginize emin misiniz? (e/h): " confirm
    
    if [ "$confirm" != "e" ]; then
        echo "Iptal edildi."
        return 0
    fi
    
    # Secilen satiri sil
    crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | sed "${line_number}d" | crontab -
    
    if [ $? -eq 0 ]; then
        echo "Cron gorevi basariyla silindi"
    else
        echo "Cron gorevi silinemedi!"
        return 1
    fi
}
remove_all_cron() {
    if ! crontab -l &>/dev/null; then
        echo "Silinecek cron gorevi yok."
        return 0
    fi
    
    echo "UYARI: Tum cron gorevleri silinecek!"
    echo ""
    list_cron_jobs
    echo ""
    read -p "TUM gorevleri silmek istediginize EMIN misiniz? (EVET yazin): " confirm
    
    if [ "$confirm" != "EVET" ]; then
        echo "Iptal edildi."
        return 0
    fi
    
    crontab -r 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Tum cron gorevleri silindi"
    else
        echo "Cron gorevleri silinemedi!"
        return 1
    fi
}
check_cron_service() {
    echo "=== Cron Servisi Durumu ==="
    echo ""
    
    if systemctl is-active --quiet cron 2>/dev/null; then
        echo "Cron servisi calisiyor"
    elif systemctl is-active --quiet crond 2>/dev/null; then
        echo "Crond servisi calisiyor"
    else
        echo "Cron servisi calismiyor!"
        echo ""
        echo "Baslatmak icin: sudo systemctl start cron"
        return 1
    fi
    
    echo ""
    systemctl status cron 2>/dev/null || systemctl status crond 2>/dev/null
}
show_cron_logs() {
    local lines="${1:-50}"
    
    echo "=== Cron Loglari (Son $lines Satir) ==="
    echo ""
    
    # journalctl ile cron loglari
    if command -v journalctl &> /dev/null; then
        journalctl -u cron -n "$lines" --no-pager 2>/dev/null || \
        journalctl -u crond -n "$lines" --no-pager 2>/dev/null
    # /var/log/syslog
    elif [ -f /var/log/syslog ]; then
        grep CRON /var/log/syslog | tail -n "$lines"
    # /var/log/cron
    elif [ -f /var/log/cron ]; then
        tail -n "$lines" /var/log/cron
    else
        echo "Cron loglari bulunamadi!"
        return 1
    fi
}