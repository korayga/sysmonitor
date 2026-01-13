#!/bin/bash

# Firewall yonetim fonksiyonlari

# Guvenlik duvari durumunu kontrol et
check_firewall_status() {
    if command -v ufw &> /dev/null; then
        sudo ufw status verbose
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --state
    else
        echo "Guvenlik duvari araci bulunamadi"
        return 1
    fi
}

# Tüm firewall kurallarını listele
list_firewall_rules() {
    if command -v ufw &> /dev/null; then
        sudo ufw status numbered
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --list-all
    elif command -v iptables &> /dev/null; then
        sudo iptables -L -n -v
    fi
}

# Port ac
allow_port() {
    local port=$1
    local protocol=${2:-tcp}
    
    if command -v ufw &> /dev/null; then
        sudo ufw allow $port/$protocol
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-port=$port/$protocol
        sudo firewall-cmd --reload
    fi
}

# Port kapat
deny_port() {
    local port=$1
    local protocol=${2:-tcp}
    
    if command -v ufw &> /dev/null; then
        sudo ufw deny $port/$protocol
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --remove-port=$port/$protocol
        sudo firewall-cmd --reload
    fi
}

# Guvenlik duvarini etkinlestir
enable_firewall() {
    if command -v ufw &> /dev/null; then
        sudo ufw --force enable
    elif command -v firewall-cmd &> /dev/null; then
        sudo systemctl start firewalld
        sudo systemctl enable firewalld
    fi
}

# Guvenlik duvarini devre disi birak
disable_firewall() {
    if command -v ufw &> /dev/null; then
        sudo ufw disable
    elif command -v firewall-cmd &> /dev/null; then
        sudo systemctl stop firewalld
    fi
}

# Kural sil
delete_rule() {
    local rule_number=$1
    
    if command -v ufw &> /dev/null; then
        sudo ufw delete $rule_number
    fi
}
