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
URLRDP="https://raw.githubusercontent.com/DOT-SUNDA/test/refs/heads/main"

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
    echo -e "\033[1;36mPILIH SERVER CLOUDSIGMA:\033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    echo -e "\033[1;36m1. Server (ZRH)\033[0m"
    echo -e "\033[1;36m2. Server (CAI)\033[0m"
    echo -e "\033[1;36m3. Server (CRK)\033[0m"
    echo -e "\033[1;36m4. Server (MNL)\033[0m"
    echo -e "\033[1;36m5. Server (MNL2)\033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    read -p "Pilih Server (1-5): " server_choice

    case $server_choice in
        1) SERVER="zrh" ;;
        2) SERVER="cai" ;;
        3) SERVER="crk" ;;
        4) SERVER="mnl" ;;
        5) SERVER="mnl2" ;;
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
    echo -e "\033[1;32m  MENU AUTO CREATE DOT AJA   \033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    echo -e "\033[1;37mOS : \033[1;34m$OS_INFO\033[0m"
    echo -e "\033[1;37mPROSES : \033[1;34m$SCREEN_STATUS\033[0m"
    echo -e "\033[1;37mWAKTU : \033[1;34m$(date)\033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    echo -e "\033[1;36m1. Buat Baru       \033[0m"
    echo -e "\033[1;36m2. Lihat Proses    \033[0m"
    echo -e "\033[1;36m3. Hentikan Proses \033[0m"
    echo -e "\033[1;36m4. Cek Daftar IP   \033[0m"
    echo -e "\033[1;36m5. Exit            \033[0m"
    echo -e "\033[1;32m=============================\033[0m"
    
    # Pilihan menu dengan efek input
    read -p "Pilih Menu : " option
    case $option in
        1)
            clear
            select_server
            print_message "Masukkan email (pisahkan dengan koma):"
            read -p "Emails: " emails
            print_message "Menjalankan proses pembuatan RDP di $SERVER..."
            screen -dmS PROP bash -c "$(wget -qO- $URLRDP/$SERVER.sh)" "$emails"
            print_message "Proses berjalan di background pada"
            print_message "Gunakan opsi 2 untuk melihat detail."
            ;;
        2)
            clear
            if screen -list | grep -q "PROP"; then
                screen -r PROP
            else
                print_error "Tidak ada proses RDP yang aktif."
            fi
            ;;
        3)
            clear
            if screen -list | grep -q "RDP_CREATION"; then
                screen -S PROP -X quit
                print_message "Semua proses RDP dihentikan."
            else
                print_error "Tidak ada proses RDP yang aktif."
            fi
            ;;
        4)
            clear
            if [ -f "rdp.txt" ]; then
                print_message "Daftar Ip Rdp:"
                cat rdp.txt
            else
                print_error "Daftar Ip Rdp tidak ditemukan."
            fi
            ;;
        5)
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