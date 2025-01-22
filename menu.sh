#!/bin/bash

# Daftar server yang tersedia
declare -A servers
servers["1"]="server1"
servers["2"]="server2"
servers["3"]="server3"

# Fungsi untuk menampilkan menu
show_menu() {
    echo "Pilih server untuk dijalankan:"
    for key in "${!servers[@]}"; do
        echo "$key) ${servers[$key]}"
    done
    echo "0) Keluar"
}

# Fungsi untuk menjalankan skrip
run_script() {
    local svr="${servers[$1]}"
    if [ -z "$svr" ]; then
        echo "Server tidak valid!"
        return
    fi

    echo "Server yang dipilih: $svr"
    echo "Masukkan daftar email (pisahkan dengan koma):"
    read emails

    # Jalankan logika skrip
    echo "Menjalankan proses pada $svr dengan email $emails..."
    ./script.sh "$emails" "$svr"
}

# Loop menu
while true; do
    show_menu
    read -p "Masukkan pilihan Anda: " choice

    case $choice in
        0)
            echo "Keluar dari menu."
            break
            ;;
        [1-9])
            run_script "$choice"
            ;;
        *)
            echo "Pilihan tidak valid. Coba lagi."
            ;;
    esac
done
