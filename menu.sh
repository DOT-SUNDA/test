#!/bin/bash

# Fungsi untuk menampilkan pesan dengan warna biru
print_message() {
    echo -e "\033[1;36m$1\033[0m"
}

# Fungsi untuk menampilkan pesan error dengan warna merah
print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

# URL untuk script Auto RDP
URLRDP="https://raw.githubusercontent.com/DOT-SUNDA/aksesroot/refs/heads/main"

# Fungsi untuk cek status screen
check_screen_status() {
    SCREEN_STATUS=$(screen -list | grep -oP '\d+\.\S+')

    if [ -z "$SCREEN_STATUS" ]; then
        SCREEN_STATUS="Tidak Aktif"
    else
        SCREEN_STATUS="Sesi aktif:\n$SCREEN_STATUS"
    fi
}

# Dapatkan informasi OS
get_os_info() {
    OS_INFO=$(grep "^PRETTY_NAME=" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    if [ -z "$OS_INFO" ]; then
        OS_INFO="Tidak diketahui"
    fi
}

# Fungsi untuk memilih server
select_server() {
    echo -e "\033[1;32m=============================\033[0m"
    echo -e "\033[1;36mPilih Server untuk RDP:\033[0m"
    echo -e "\033[1;36m1. Server 1 (svr1)\033[0m"
    echo -e "\033[1;36m2. Server 2 (svr2)\033[0m"
    echo -e "\033[1;36m3. Server 3 (svr3)\033[0m"
    echo -e "\033[1;36m4. Server 4 (svr4)\033[0m"
    echo -e "\033[1;36m5. Server 5 (svr5)\033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    read -p "Pilih Server (1-5): " server_choice

    case $server_choice in
        1) SERVER="svr1" ;;
        2) SERVER="svr2" ;;
        3) SERVER="svr3" ;;
        4) SERVER="svr4" ;;
        5) SERVER="svr5" ;;
        *)
            print_error "Pilihan tidak valid! Silakan pilih angka antara 1-5."
            select_server
            ;;
    esac
}

# Menu utama
while true; do
    # Refresh status screen dan OS info
    check_screen_status
    get_os_info
    
    # Tampilan header
    clear
    echo -e "\033[1;32m=============================\033[0m"
    echo -e "\033[1;32m    MENU AUTO CREATE RDP     \033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    echo -e "\033[1;37mOS       : \033[1;34m$OS_INFO\033[0m"
    echo -e "\033[1;37mScreen   : \033[1;34m$SCREEN_STATUS\033[0m"
    echo -e "\033[1;37mWaktu    : \033[1;34m$(date)\033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    echo -e "\033[1;36m1. Buat RDP Baru      \033[0m"
    echo -e "\033[1;36m2. Lihat Proses RDP   \033[0m"
    echo -e "\033[1;36m3. Hentikan Semua RDP \033[0m"
    echo -e "\033[1;36m4. Exit               \033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    
    # Pilihan menu dengan efek input
    read -p "Pilih Menu : " option
    case $option in
        1)
            clear
            select_server
            print_message "Masukkan daftar email (pisahkan dengan koma):"
            read -p "Emails: " emails
            print_message "Menjalankan proses pembuatan RDP di $SERVER..."
            screen -dmS RDP_CREATION bash -c "$(wget -qO- $URLRDP/auto.sh)" "$emails" "$SERVER"
            print_message "Proses RDP berjalan di background pada server $SERVER. Gunakan opsi 2 untuk melihat detail."
            ;;
        2)
            clear
            if screen -list | grep -q "RDP_CREATION"; then
                screen -r RDP_CREATION
            else
                print_error "Tidak ada proses RDP yang aktif."
            fi
            ;;
        3)
            clear
            if screen -list | grep -q "RDP_CREATION"; then
                screen -S RDP_CREATION -X quit
                print_message "Semua proses RDP dihentikan."
            else
                print_error "Tidak ada proses RDP yang aktif."
            fi
            ;;
        4)
            clear
            echo -e "\033[1;31mKeluar...\033[0m"
            exit 0
            ;;
        *)
            print_error "Pilihan tidak valid! Silakan pilih angka antara 1-4."
            ;;
    esac
    echo ""
    read -p "Tekan [Enter] untuk melanjutkan..."
done
