#!/bin/bash
svr="mnl"
password="Dotaja123@HHHH"
emails="$1"

if ! command -v jq &> /dev/null; then
    echo "jq tidak ditemukan, pastikan jq terpasang."
    exit 1
fi

# Validasi argumen email
if [ -z "$1" ]; then
    echo "Tidak ada email yang diberikan."
    exit 1
fi

# Cek file idserver.txt
if [ ! -f "idserver.txt" ]; then
    echo "File idserver.txt tidak ditemukan!"
    exit 1
fi

# Ubah daftar email menjadi array
IFS=',' read -r -a email_array <<< "$emails"

# Baca ID server dari file idserver.txt
mapfile -t server_ids < idserver.txt

# Loop melalui setiap email dan ID server
for index in "${!email_array[@]}"; do
    email="${email_array[$index]}"
    server_id="${server_ids[$index]}"

    # Buat token otentikasi
    auth_token=$(echo -n "$email:$password" | base64)

    # Jalankan server
    echo "Menjalankan server untuk ID: $server_id dengan akun $email..."
    run_response=$(curl -s -X POST "https://$svr.cloudsigma.com/api/2.0/servers/$server_id/action/?do=start" \
                       -H "Content-Type: application/json" \
                       -H "Authorization: Basic $auth_token" \
                       -d '{}')
    echo "Server dijalankan. Response: $run_response"

    sleep 30
    
    # Dapatkan IP server
    ip=$(curl -s -X GET "https://$svr.cloudsigma.com/api/2.0/servers/$server_id/" \
              -H "Content-Type: application/json" \
              -H "Authorization: Basic $auth_token" | jq -r '.runtime.nics[0].ip_v4.uuid')

    # Menyimpan IP ke RDP.TXT
    echo "$ip" >> rdpbaru.txt
    # Menampilkan IP
    echo "IP Address: $ip"
done
cat rdpbaru.txt
# Keluar setelah selesai
exit
