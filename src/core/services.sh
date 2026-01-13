#!/bin/bash

#servis islemleri
#services.sh <arg>      arg=(running or dead or failed or all)
list_services(){
local filter=${1:-all} 

    case "$filter" in

    #--type=service => Sadece servisleri göster
    #--no-pager     => Sayfa sayfa gösterme hepsini bas
    #--no-legend    => Başlık satırlarını gösterme

    "running")  
            systemctl list-units --type=service --state=running --no-pager --no-legend | \
            awk '{print $1}' | sed 's/.service$//' # birinci sutunu al .services kısmını hicibi ile degistir
                ;;

    "dead") 
            systemctl list-units --type=services --state=dead --no-pager --no-legend | \
            awk '{print $1}' | sed 's/.service$//'
                ;;
    "failed")
            systemctl list-units --type=service --state=failed --no-pager --no-legend | \
            awk '{print $1}' | sed 's/.service$//'
            ;;
    "all")
            systemctl list-unit-files --type=service --no-pager --no-legend | \
            awk '{print $1}' | sed 's/.service$//'
            ;;
    *)
            echo "Hata: Geçersiz filtre. Kullanim: running, dead, failed, all"
            return 1
            ;;

    esac

}

status_sevice(){
   local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Hata: Servis adi belirtilmedi!"
        return 2
    fi

    durum=$(systemctl status "$service_name" --no-pager 2>/dev/null)
    
    if [ -z "$durum" ]; then
        echo "notfound"
        return 1
    fi
    
    echo $durum 
                 #return 0-255 kabul eder | return string dondurmek icin echo kullanildi
}


is_service_active() {
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi"
        return 2
    fi
    
    if systemctl is-active --quiet "$service_name" 2>/dev/null; then
        return 0  #active
    else
        return 1  #inactive
    fi
}

is_service_enabled() {
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi"
        return 2
    fi
    
    if systemctl is-enabled --quiet "$service_name" 2>/dev/null; then
        return 0  #enabled
    else
        return 1  #disabled
    fi
}

get_service_info(){
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Hata: Servis adi belirtilmedi!"
        return 2
    fi
    
    echo "DURUM:"

    if is_service_active "$service_name" ;then
        echo " Aktif"
    else
        echo " Inaktif"
    fi

    if is_service_enabled "$service_name"; then
        echo " Enabled"
    else
        echo " Disabled"
    fi

    echo -e "\n Detaylar: "
    durum=$(status_sevice "$service_name") #status_service çalıştırıldı çıktısı Duruma kaydedildi
    echo "$durum"
}

start_service(){
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi!"
        return 1
    fi
    
    #Root kontrolü
    if [ "$EUID" -ne 0 ]; then
        echo "Yetki hatasi"
        echo "Kullanim: sudo $0"
        return 1
    fi

    if systemctl start "$service_name" 2>/dev/null;then
        echo "Başariyla başlatildi"
        return 0
    else
        echo "$service_name başlatilamadi!"
        return 1
    fi
}

stop_service(){
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi!"
        return 1
    fi
    
    #Root kontrolü
    if [ "$EUID" -ne 0 ]; then
        echo "Yetki hatasi"
        echo "Kullanim: sudo $0"
        return 1
    fi

    if systemctl stop "$service_name" 2>/dev/null;then
        echo "Başariyla durduruldu"
        return 0
    else
         echo "$service_name durdurulamadi"
        return 1
    fi
}
restart_service(){
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi"
        return 1
    fi
    
    #Root kontrolü
    if [ "$EUID" -ne 0 ]; then
        echo "Yetki hatasi"
        echo "Kullanim: sudo $0"
        return 1
    fi

    if systemctl restart "$service_name" 2>/dev/null;then
        echo "Başariyla yeniden başlatildi"
        return 0
    else
         echo "$service_name yeniden başlatilamadi"
    fi
        return 1
}
reload_service(){
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi"
        return 1
    fi
    
    #Root kontrolu
    if [ "$EUID" -ne 0 ]; then
        echo "Yetki hatasi"
        echo "Kullanim: sudo $0"
        return 1
    fi

    if systemctl reload "$service_name" 2>/dev/null;then
        echo "Basariyla yenilendi"
        return 0
    else
         echo "$service_name yenilenemedi"
    fi
        return 1
}

enable_service() {
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi!"
        return 1
    fi
    
    #Root kontrolu
    if [ "$EUID" -ne 0 ]; then
        echo "Yetki hatasi"
        echo "Kullanim: sudo $0"
        return 1
    fi
    
    if systemctl enable "$service_name" 2>/dev/null; then
        echo "$service_name boot'ta baslatilacak sekilde ayarlandi"
        return 0
    else
        echo "$service_name enable edilemedi"
        return 1
    fi
}
disable_service() {
    local service_name="$1"
    
    if [ -z "$service_name" ]; then
        echo "Servis adi belirtilmedi!"
        return 1
    fi
    
    #Root kontrolu
    if [ "$EUID" -ne 0 ]; then
        echo "Yetki hatasi"
        echo "Kullanim: sudo $0"
        return 1
    fi
    
    echo "Servis boot'ta baslatilacak: $service_name"
    
    if systemctl disable "$service_name" 2>/dev/null; then
        echo "$service_name boot'tan kaldirildi"
        return 0
    else
        echo "$service_name disable edilemedi"
        return 1
    fi
}
count_services() {
    echo "Servis Istatistikleri"
    echo ""
    echo "Calisan Servisler: $(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)"
    echo "Durmus Servisler: $(systemctl list-units --type=service --state=dead --no-pager --no-legend | wc -l)"
    echo "Basarisiz Servisler: $(systemctl list-units --type=service --state=failed --no-pager --no-legend | wc -l)"
    echo "Toplam Servis: $(systemctl list-unit-files --type=service --no-pager --no-legend | wc -l)"
}