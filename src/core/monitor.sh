#!/bin/bash

get_cpu_usage() {
   
    # usr=$(mpstat | tail -2 | awk '{print $4}')
    # sys=$(mpstat | tail -2 | awk '{print $6}')
    # echo "usrCPU: "$usr" "
    # echo "sysCPU: "$sys" " 

    mpstat | tail -2

}
get_tasks(){
    top -bn1 | grep "Tasks" 
}
get_ram_usage() {
    free | grep "Mem"| awk '{printf "%.1f", ($3/$2) * 100.0}'
}
get_ram_free() {
    free | grep "Mem"| awk '{printf "%.1f", ($4/$2) * 100.0}'
}

get_ram_detailed() {
    echo "=== RAM Kullanim Detaylari ==="
    echo ""
    
    # free komutundan bilgileri al
    local total=$(free -m | awk '/Mem:/ {print $2}')
    local used=$(free -m | awk '/Mem:/ {print $3}')
    local free=$(free -m | awk '/Mem:/ {print $4}')
    local available=$(free -m | awk '/Mem:/ {print $7}')
    local percent=$(get_ram_usage)
    
    echo "Toplam RAM:     ${total} MB"
    echo "Kullanilan:     ${used} MB"
    echo "Bos:            ${free} MB"
    echo "Kullanilabilir: ${available} MB"
    echo "Kullanim Orani: ${percent}%"
    
    echo ""
    echo "--- Swap Bilgisi ---"
    local swap_total=$(free -m | awk '/Swap:/ {print $2}')
    local swap_used=$(free -m | awk '/Swap:/ {print $3}')
    
    if (( swap_total > 0 )); then
        local swap_percent=$(( (swap_used * 100) / swap_total ))
        echo "Swap Toplam:    ${swap_total} MB"
        echo "Swap Kullanim:  ${swap_used} MB (${swap_percent}%)"
    else
        echo "Swap alani yok"
    fi
}
get_disk_usage() {
    local size=$(df -h | grep "^/dev/" | awk '{print $2}')
    local used=$(df -h | grep "^/dev/" | awk '{print $3}')
    local avb=$(df -h | grep "^/dev/" | awk '{print $4}')
    local use_p=$(df -h | grep "^/dev/" | awk '{print $5}')
  
    echo "Toplam disk:     ${size} GB"
    echo "Kullanilan:     ${used} GB"
    echo "Kullanilabilir: ${avb} GB"
    echo "Kullanim Orani: ${use_p}%"

}

# Kullanim: get_directory_size "/var/log"
get_directory_size() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        echo "Hata: $dir dizini bulunamadi"
        return 1
    fi
    
    du -sh "$dir" 2>/dev/null | awk '{print $1}'
} 
#Kullanım: get_largest_files "/home"
get_largest_files() {
    local dir="${1:-.}"  

    find "$dir" -type f -exec du -h {} + 2>/dev/null | sort -rh | head
}
get_process_count() {
    ps aux | wc -l
}
get_top_cpu_processes() {

    ps aux --sort=-%cpu | head | awk '{printf "%-10s %-10s %-10s %s\n", $2, $1, $3, $11}'

}

# Kullanim: find_process "nginx"
find_process() {
    local process_name="$1"
    
    if [ -z "$process_name" ]; then
        echo "Hata: Surec adi belirtilmedi"
        return 1
    fi
    
    ps aux | grep "$process_name" | grep -v grep
}


show_process_tree() {
    if command -v pstree &> /dev/null; then
        pstree -p
    else
        ps auxf
    fi
}


find_zombie_processes() {
   
    
    local zombies_pid=$(ps aux | awk '{if($8=="Z") print $2}') #eger stat sutunu Z ile isaretliyse pidsini tut
    
    if [ -z "$zombies_pid" ]; then
        echo "Zombie surec bulunamadi"
    else
        echo "$zombies_pid"
    fi
}

kill_zombie_process() {
    local zombie_pid="$1"
    
    if [ -z "$zombie_pid" ]; then
        echo "Hata: PID belirtilmedi!"
        return 1
    fi
    
    # Zombie surec mi kontrol et
    local status=$(ps -p "$zombie_pid" -o stat= 2>/dev/null | tr -d ' ')
    
    if [ -z "$status" ]; then
        echo "Hata: PID $zombie_pid bulunamadi!"
        return 1
    fi
    
    if [ "$status" != "Z" ]; then
        echo "Uyari: PID $zombie_pid zombie surec degil (stat: $status)"
        return 1
    fi
    
    # Zombie surecin parent PID'sini bul
    local ppid=$(ps -p "$zombie_pid" -o ppid= 2>/dev/null | tr -d ' ')
    
    if [ -z "$ppid" ]; then
        echo "Hata: Parent PID bulunamadi!"
        return 1
    fi
    
    echo "Zombie Surec PID: $zombie_pid"
    echo "Parent PID: $ppid"
    echo ""
    echo "Zombie sureci temizlemek icin parent sureci yeniden baslatmak gerekir."
    echo ""
    
    # Parent surecin adini goster
    local parent_name=$(ps -p "$ppid" -o comm= 2>/dev/null)
    echo "Parent Surec: $parent_name (PID: $ppid)"
    echo ""
    
    read -p "Parent sureci sonlandirmak istiyor musunuz? (e/h):" confirm
    
    if [ "$confirm" = "e" ]; then
        sudo kill -15 "$ppid" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Parent surec sonlandirildi. Zombie surec temizlenecek."
            sleep 2
            
            # Kontrol et
            if ! ps -p "$zombie_pid" &>/dev/null; then
                echo "Basarili: Zombie surec temizlendi!"
            else
                echo "Uyari: Zombie surec hala mevcut. SIGKILL deneniyor..."
                sudo kill -9 "$ppid" 2>/dev/null
            fi
        else
            echo "Hata: Parent surec sonlandirilamadi!"
            return 1
        fi
    else
        echo "Iptal edildi."
        return 0
    fi
}




get_system_summary() {
    
    echo "          SISTEM DURUMU OZETI"

    echo ""
    
    # Sistem bilgileri
    echo "┌─ Sistem Bilgileri"
    echo "│  Hostname:    $(hostname)"
    echo "│  OS:          $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || uname -s)"
    echo "│  Kernel:      $(uname -r)"
    echo "│  Uptime:      $(uptime -p 2>/dev/null || uptime | awk '{print $3, $4}')"
    echo "└─"
    echo ""
    
    # CPU
    local cpu_usage=$(get_cpu_usage)
    echo "┌─ CPU"
    echo "│  Kullanim:    ${cpu_usage}%"
    echo "│  Cekirdek:    $(nproc)"
    echo "│  Load Avg:    $(uptime | awk -F'load average:' '{print $2}' | awk -F, '{print $1}' | xargs)"
    echo "└─"
    echo ""
    
    # RAM
    local ram_percent=$(get_ram_usage)
    local ram_used=$(free -m | awk '/Mem:/ {print $3}')
    local ram_total=$(free -m | awk '/Mem:/ {print $2}')
    echo "┌─ RAM"
    echo "│  Kullanim:    ${ram_percent}%"
    echo "│  Detay:       ${ram_used}MB / ${ram_total}MB"
    echo "└─"
    echo ""
    
    # Disk
    local disk_percent=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')
    echo "┌─ Disk (Root)"
    echo "│  Kullanim:    ${disk_percent}%"
    df -h / | tail -1 | awk '{printf "│  Detay:       %s / %s kullaniliyor\n", $3, $2}'
    echo "└─"
    echo ""
    
    
    
    # Surecler
    echo "┌─ Surecler"
    echo "│  Toplam:      $(get_process_count)"
    echo "│  Calisan:     $(ps aux | awk '{if($8=="R") print $0}' | wc -l)"
    echo "└─"
    echo ""
    
    echo "Rapor Zamani: $(date '+%Y-%m-%d %H:%M:%S')"
}


# Kullanim: monitor_continuous 
monitor_continuous() {
    
    echo "      Surekli izleme modu"
    echo "Cikmak icin CTRL+C basin"
    echo ""
    
    while true; do
        clear
        get_system_summary
        sleep 5
    done
}


check_resource_warnings() {
    echo "      Kaynak Uyari Kontrolu"
    echo ""
    
    local warnings=0
    
    # CPU kontrolu
    local cpu_usage=$(get_cpu_usage | cut -d. -f1)
    if (( cpu_usage > 80 )); then
        echo "UYARI: CPU kullanimi yuksek! (%${cpu_usage})"
        warnings=$((warnings + 1))
    fi
    
    # RAM kontrolu
    local ram_usage=$(get_ram_usage | cut -d. -f1)
    if (( ram_usage > 80 )); then
        echo "UYARI: RAM kullanimi yuksek! (%${ram_usage})"
        warnings=$((warnings + 1))
    fi
    
    # Disk kontrolu
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')
    if (( disk_usage > 80 )); then
        echo "UYARI: Disk kullanimi yuksek! (%${disk_usage})"
        warnings=$((warnings + 1))
    fi
    
    # Zombie surec kontrolu
    local zombie_pids=$(find_zombie_processes)
    if [ "$zombie_pids" != "Zombie surec bulunamadi" ]; then
        local zombie_count=$(echo "$zombie_pids" | wc -w)
        echo "UYARI: $zombie_count zombie surec bulundu!"
        warnings=$((warnings + 1))
    fi
    
    # Sonuc
    if (( warnings == 0 )); then
        echo "Sistem kaynaklarinda sorun tespit edilmedi"
    else
        echo ""
        echo "Toplam $warnings uyari bulundu!"
    fi
}