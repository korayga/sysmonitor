#!/bin/bash

# Kullanım show_logs <n>
show_logs(){

    local lines="${1:-100}"
    echo "        son  $lines satir log:"
    echo ""

    if journalctl -n "$lines" -e -r --no-pager 2>/dev/null ;then
        return 0
    else 
        echo "Hata! sudo $0 $1 ile tekrar deneyiniz"
    fi

}
# Kullanim: show_logs_since "2025-12-27 10:00:00"
show_logs_since() {
    
    local since_time="$1"

      if [ -z "$since_time" ]; then
        echo "Zaman belirtilmedi!"
        echo "Kullanim: $0 'YYYY-MM-DD'"
        echo "Ornek: $0 '2025-12-27'"
        return 1
    fi

    journalctl --since "$since_time" --no-pager 2>/dev/null
}
show_today_logs() {
    echo "      Bugunku Loglari"
    echo ""
    
    journalctl --since today --no-pager 2>/dev/null
}
show_last_hour_logs() {
    echo "      Son 1 Saatin Loglari"
    echo ""
    
    journalctl --since "1 hour ago" --no-pager 2>/dev/null
}
follow_logs(){
    local service_name=$1

if [ -z "$service_name" ]; then
        echo "      Canli Sistem Log Izleme (CTRL+C ile cikis)"
        echo ""
        journalctl -f --no-pager 2>/dev/null
    else
        echo "      $service_name Canli Log Izleme (CTRL+C ile cikis)"
        echo ""
        journalctl -u "$service_name" -f --no-pager 2>/dev/null
    fi

}
show_error_logs() {
    local lines="${1:-100}"
    
    echo "      Son $lines Hata Logu"
    echo ""
    
    # Priority: 0=emerg, 1=alert, 2=crit, 3=err, 4=warning, 5=notice, 6=info, 7=debug
    journalctl -p err -n "$lines" --no-pager 2>/dev/null
}


show_critical_logs() {
    local lines="${1:-100}"
    
    echo "      Son $lines Kritik Log"
    echo ""
    
    journalctl -p crit -n "$lines" --no-pager 2>/dev/null
}
show_warning_logs() {
    local lines="${1:-100}"
    
    echo "      Son $lines Uyari Logu"
    echo ""
    
    journalctl -p warning -n "$lines" --no-pager 2>/dev/null
}
search_log(){

    local keyword="$1"
    local lines="${2:-50}"

    if [ -z "$keyword" ]; then
        echo "Kullanim: $0 <kelime> [satir_sayisi]"
        return 1
    fi
    
    echo "      '$keyword' Kelimesini Iceren Loglar (Son $lines)"
    echo ""

    journalctl -n "$lines" --no-pager 2>/dev/null | grep -i "$keyword"

}
show_log_file() {
    local logfile="$1"
    local lines="${2:-100}"
    
    if [ -z "$logfile" ]; then
        echo "Kullanim: $0 <dosya_yolu> [satir]"
        return 1
    fi
    
    if [ ! -f "$logfile" ]; then
        echo "Hata: $logfile dosyasi bulunamadi!"
        return 1
    fi
    
    echo "      $logfile (Son $lines Satir)"
    echo ""
    
    tail -n "$lines" "$logfile" 2>/dev/null
}
search_service_log(){
    local service_name=$1
    local keyword="${2:-error}"
    local lines="${3:-50}"

    if [ -z "$service_name" ]; then
    
        echo "Kullanim: $0 <servis> <kelime> [satir]"
        return 1
    fi
    
    echo "      $service_name Servisinde '$keyword' Aramasi"
    echo ""

    journalctl -u "$service_name" -n "$lines" --no-pager 2>/dev/null | grep -i "$keyword"

}
show_syslog() {
    local lines="${1:-100}"
    
    if [ -f /var/log/syslog ]; then
        show_log_file "/var/log/syslog" "$lines"
    elif [ -f /var/log/messages ]; then
        show_log_file "/var/log/messages" "$lines"
    else
        echo "Syslog dosyasi bulunamadi!"
        return 1
    fi
}

analyze_common_errors() {
    local count="${1:-10}"
    
    echo "      En Cok Gorulen $count Hata Mesaji"
    echo ""
    
    journalctl -p err --no-pager 2>/dev/null | \
    sed -n 's/.*\] //p'| \
    sort | uniq -c | sort -rn | head -n "$count" | \
    awk '{$1=$1; print NR". ("$1"x) "$0}' | sed 's/^[0-9]*\. /&\n   /'
}


log_statistics() {
    echo "      Log Istatistikleri"
    echo ""
    
    # Toplam log girisi
    local total=$(journalctl --no-pager 2>/dev/null | wc -l)
    echo "Toplam Log Girisi: $total"
    echo ""
    
    # Seviyeye gore dagilim
    echo "Seviyeye Gore Dagilim:"
    echo "  Emergency : $(journalctl -p emerg --no-pager 2>/dev/null | wc -l)"
    echo "  Alert     : $(journalctl -p alert --no-pager 2>/dev/null | wc -l)"
    echo "  Critical  : $(journalctl -p crit --no-pager 2>/dev/null | wc -l)"
    echo "  Error     : $(journalctl -p err --no-pager 2>/dev/null | wc -l)"
    echo "  Warning   : $(journalctl -p warning --no-pager 2>/dev/null | wc -l)"
    echo ""
    
    # Bugunku loglar
    local today_count=$(journalctl --since today --no-pager 2>/dev/null | wc -l)
    echo "Bugunku Log Sayisi: $today_count"
    
    # Journal disk kullanimi
    echo ""
    echo "Journal Disk Kullanimi:"
    journalctl --disk-usage 2>/dev/null
}
show_failed_logins() {
    local lines="${1:-20}"
    
    echo "      Basarisiz Login Girisimleri (Son $lines)"
    echo ""
    
    if [ -f /var/log/auth.log ]; then
        grep "Failed password" /var/log/auth.log | tail -n "$lines"
    elif [ -f /var/log/secure ]; then
        grep "Failed password" /var/log/secure | tail -n "$lines"
    else
        journalctl -u ssh -p err --no-pager 2>/dev/null | grep -i "failed" | tail -n "$lines"
    fi
}
show_reboot_logs() {
    echo "      Sistem Reboot Gecmisi"
    echo ""
    
    if command -v last &> /dev/null; then
        last reboot | head -20
    else
        journalctl --list-boots --no-pager 2>/dev/null
    fi
}

limit_journal_size() {
    local size="$1"
    
    if [ -z "$size" ]; then
        echo "Kullanım: $0 <boyut>"
        echo "Örnek: $0 500M"
        return 1
    fi
    
    if [ "$EUID" -ne 0 ]; then
        echo "Hata: Bu işlem için root yetkileri gerekli!"
        return 1
    fi
    
    echo "Journal boyutu $size ile sinirlaniyor..."
    journalctl --vacuum-size="$size" 2>/dev/null
}


clean_old_logs() {
    local time="$1"
    
    if [ -z "$time" ]; then
        echo "Kullanim: $0 <zaman>"
        echo "Örnek: $0 7d (7 günden eski)"
        return 1
    fi
    
    if [ "$EUID" -ne 0 ]; then
        echo "Hata: Bu işlem için root yetkileri gerekli!"
        return 1
    fi
    
    echo "$time süresinden eski loglar temizleniyor..."
    journalctl --vacuum-time="$time" 2>/dev/null
}

export_logs() {
    local output_file="$1"
    local lines="${2:-1000}"
    
    if [ -z "$output_file" ]; then
      
        echo "Kullanim: $0 <dosya_adi> [satir_sayisi]"
        return 1
    fi
    
    echo "Son $lines satir log $output_file dosyasina kaydediliyor..."
    
    journalctl -n "$lines" --no-pager > "$output_file" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Loglar basariyla kaydedildi: $output_file"
        echo "Dosya boyutu: $(du -h "$output_file" | awk '{print $1}')"
    else
        echo "Log kaydedilemedi!"
        return 1
    fi
}


export_error_logs() {
    local output_file="$1"
    local lines="${2:-500}"
    
    if [ -z "$output_file" ]; then
        echo "Hata: Cikti dosyasi belirtilmedi!"
        return 1
    fi
    
    echo "Son $lines satir hata logu $output_file dosyasina kaydediliyor..."
    
    journalctl -p err -n "$lines" --no-pager > "$output_file" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Hata loglari basariyla kaydedildi: $output_file"
    else
        echo "Log kaydedilemedi!"
        return 1
    fi
}