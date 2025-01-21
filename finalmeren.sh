#!/bin/bash
svr="$0"
wcpu="3200"
# Password tetap
password="Dotaja123@HHHH"
emails="$1"
file="dotaja"
server_name="memek"
vnc_password="kontoljembud"


if ! command -v jq &> /dev/null; then
    echo "jq tidak ditemukan, pastikan jq terpasang."
    exit 1
fi

# Validasi argumen email
if [ -z "$1" ]; then
    echo "Tidak ada email yang diberikan."
    exit 1
fi

# Cek file untuk upload
if [ ! -f "$file" ]; then
    echo "File $file tidak ditemukan!"
    exit 1
fi

# Ubah daftar email menjadi array
IFS=',' read -r -a email_array <<< "$emails"

for email in "${email_array[@]}"; do
    # Buat token otentikasi
    auth_token=$(echo -n "$email:$password" | base64)

    # Upload file
    echo "Mengupload file dengan akun $email..."
    drive_id=$(curl --silent --request POST --user "$email:$password" \
                            --header 'Content-Type: application/octet-stream' \
                            --upload-file "$file" \
                            "https://direct.$svr.cloudsigma.com/api/2.0/drives/upload/")
    if [ -z "$drive_id" ]; then
        echo "Gagal mendapatkan Drive ID untuk $email. Response: $drive_id"
        continue
    fi
    echo "Upload selesai. Drive ID: $drive_id"

    # Buat server
    echo "Membuat server untuk $email..."
    server_response=$(curl -X POST "https://$svr.cloudsigma.com/api/2.0/servers/" \
                           -H "Content-Type: application/json" \
                           -H "Authorization: Basic $auth_token" \
                           -d '{
                               "objects": [
                                   {
                                       "cpu": 3200,
                                       "mem": 2147483648,
                                       "name": "'"$server_name"'",
                                       "vnc_password": "'"$vnc_password"'",
                                       "hv_relaxed": true,
                                       "hv_tsc": true,
                                       "drives": [
                                           {
                                               "boot_order": 1,
                                               "dev_channel": "0:0",
                                               "device": "ide",
                                               "drive": "'"$drive_id"'",
                                               "size": 10
                                           }
                                       ],
                                       "nics": [
                                           {
                                               "ip_v4_conf": {"conf": "dhcp"},
                                               "model": "e1000"
                                           }
                                       ]
                                   }
                               ]
                           }')

    server_id=$(echo "$server_response" | jq -r '.objects[0].uuid') >> idserver.txt
    if [ -z "$server_id" ]; then
        echo "Gagal membuat server untuk $email. Response: $server_response"
        continue
    fi
    echo "Server dibuat. ID: $server_id"

    # Jalankan server
    echo "Menjalankan server untuk ID: $server_id..."
    run_response=$(curl -X POST "https://$svr.cloudsigma.com/api/2.0/servers/$server_id/action/?do=start" \
                       -H "Content-Type: application/json" \
                       -H "Authorization: Basic $auth_token" \
                       -d '{}')
    echo "Server dijalankan. Response: $run_response"

    sleep 30
    
    # Dapatkan IP server
    ip=$(curl -X GET "https://$svr1.cloudsigma.com/api/2.0/servers/$server_id/" \
    -H "Content-Type: application/json" \
    -H "Authorization: Basic $auth_token" | jq -r '.runtime.nics[0].ip_v4.uuid')

    # Menyimpan IP ke RDP.TXT
    echo "$ip" >> rdp.txt
    # Menampilkan IP
    echo "IP Address: $ip"
done

# Keluar setelah selesai
exit
