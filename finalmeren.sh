#!/bin/bash

# Menyimpan password yang tetap sama
password="Dotaja123@HHHH"

# Mengecek apakah ada argumen email yang diberikan
if [ -z "$1" ]; then
    echo "Tidak ada email yang diberikan."
    exit 1
fi

# Daftar email dipisahkan dengan koma
emails="$1"

# URL API untuk upload file dan file yang akan diupload
url_upload="https://direct.mnl.cloudsigma.com/api/2.0/drives/upload/"
file="dotaja"

# URL API untuk membuat server
url_server="https://mnl.cloudsigma.com/api/2.0/servers/"

server_name="dotaja"
vnc_password="kontoljembud"

# Mengecek apakah file yang akan diupload ada
if [ ! -f "$file" ]; then
    echo "File $file tidak ditemukan!"
    exit 1
fi

# Mengubah daftar email menjadi array
IFS=',' read -r -a email_array <<< "$emails"

# Loop melalui semua email untuk mengupload file
for email in "${email_array[@]}"; do
    # Membuat auth_token dalam base64 dari email:password
    auth_token=$(echo -n "$email:$password" | base64)

    # Menjalankan curl untuk mengupload file
    echo "Mengupload dengan akun $email..."
    upload_response=$(curl --request POST --user "$email:$password" \
                            --header 'Content-Type: application/octet-stream' \
                            --upload-file "$file" \
                            "$url_upload")
    
    echo "Upload selesai untuk $email."

    # Menyimpan output dari upload (misalnya ID drive) untuk digunakan dalam pembuatan server
    drive_id=$(echo "$upload_response" | jq -r '.id')
    
    if [ -z "$drive_id" ]; then
        echo "Gagal mendapatkan ID drive dari upload untuk $email!"
        continue
    fi

    # Membuat server menggunakan drive ID yang didapat dari upload
    echo "Membuat server untuk akun $email..."
    server_response=$(curl -X POST "$url_server" \
                           -H "Content-Type: application/json" \
                           -H "Authorization: Basic $auth_token" \
                           -d '{
                               "objects": [
                                   {
                                       "cpu": 3200,
                                       "mem": 2147483648,
                                       "name": "'"$server_name"'",
                                       "vnc_password": "'"$vnc_password"'",
                                       "drives": [
                                           {
                                               "boot_order": 1,
                                               "dev_channel": "0:0",
                                               "device": "ide",
                                               "drive": "'"$drive_id"'",
                                               "size": 50
                                           }
                                       ],
                                       "nics": [
                                           {
                                               "boot_order": null,
                                               "firewall_policy": null,
                                               "ip_v4_conf": {
                                                   "conf": "dhcp",
                                                   "ip": null
                                               },
                                               "ip_v6_conf": null,
                                               "mac": null,
                                               "model": "e1000",
                                               "runtime": null,
                                               "vlan": null
                                           }
                                       ]
                                   }
                               ]
                           }')
    
    # Menampilkan response dari pembuatan server
    echo "Server dibuat untuk $email: $server_response"
done
