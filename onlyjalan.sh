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

# Ubah daftar email menjadi array
IFS=',' read -r -a email_array <<< "$emails"

for email in "${email_array[@]}"; do
    # Buat token otentikasi
    auth_token=$(echo -n "$email:$password" | base64)

    # Ambil daftar server yang ada
    echo "Mengambil daftar server untuk akun $email..."
    server_list=$(curl -s -X GET "https://$svr.cloudsigma.com/api/2.0/servers/" \
                       -H "Content-Type: application/json" \
                       -H "Authorization: Basic $auth_token")

    # Ambil ID server pertama dari daftar
    server_id=$(echo "$server_list" | jq -r '.objects[0].uuid')
    if [ -z "$server_id" ] || [ "$server_id" == "null" ]; then
        echo "Tidak ada server yang ditemukan untuk akun $email."
        continue
    fi
    echo "Server ditemukan. ID: $server_id"

    # Jalankan server
    echo "Menjalankan server untuk ID: $server_id..."
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
    echo "$ip" >> barurdp.txt
    # Menampilkan IP
    echo "IP Address: $ip"
done
cat barurdp.txt
# Keluar setelah selesai
exit
