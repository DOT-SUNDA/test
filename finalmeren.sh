#!/bin/bash

# Password tetap
password="Dotaja123@HHHH"

# Validasi argumen email
if [ -z "$1" ]; then
    echo "Tidak ada email yang diberikan."
    exit 1
fi

emails="$1"
url_upload="https://direct.mnl2.cloudsigma.com/api/2.0/drives/upload/"
file="dotaja"
url_server="https://mnl2.cloudsigma.com/api/2.0/servers/"
server_name="memek"
vnc_password="kontoljembud"

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
                            "$url_upload")
    if [ -z "$drive_id" ]; then
        echo "Gagal mendapatkan Drive ID untuk $email. Response: $upload_response"
        continue
    fi
    echo "Upload selesai. Drive ID: $drive_id"

    # Buat server
    echo "Membuat server untuk $email..."
    server_response=$(curl -X POST "$url_server" \
                           -H "Content-Type: application/json" \
                           -H "Authorization: Basic $auth_token" \
                           -d '{
                               "objects": [
                                   {
                                       "cpu": 3100,
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

    server_id=$(echo "$server_response" | jq -r '.objects[0].uuid')
    if [ -z "$server_id" ]; then
        echo "Gagal membuat server untuk $email. Response: $server_response"
        continue
    fi
    echo "Server dibuat. ID: $server_id"

    # Jalankan server
    echo "Menjalankan server untuk ID: $server_id..."
    run_response=$(curl -X POST "$url_server/$server_id/action/?do=start" \
                       -H "Content-Type: application/json" \
                       -H "Authorization: Basic $auth_token" \
                       -d '{}')
    echo "Server dijalankan. Response: $run_response"

    # Dapatkan IP server
    server_ip=$(curl -X GET "$url_server/$server_id/" \
                       -H "Content-Type: application/json" \
                       -H "Authorization: Basic $auth_token" | jq -r '.runtime.nics[0].ip_v4.uuid')
    
    echo "Server IP untuk $email: $server_ip"
    
    # Simpan ke file
    echo "$server_ip" >> RDP.txt
done
