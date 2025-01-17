#!/bin/bash
svr="cwl"
wcpu="3200"
# Password tetap
password="mahesw@R123qwe"
emails="vzb64vsm@gmailo.net"
server_name="memek"
vnc_password="kontoljembud"

# Ubah daftar email menjadi array
IFS=',' read -r -a email_array <<< "$emails"

for email in "${email_array[@]}"; do
    # Buat token otentikasi
    auth_token=$(echo -n "$email:$password" | base64)

    # Upload file
    echo "Mengupload file dengan akun $email..."
    drive_id=$(curl -s -X POST POST "https:///$svr.cloudsigma.com/api/2.0/libdrives/29792cde-c093-4a6a-9d66-6849331ba0ff/action/?do=clone" \
                            -H "Content-Type: application/json" \
                            -H "Authorization: Basic $auth_token" \
                            -d '{}' | jq -r '.objects[0].uuid')
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
    echo "$ip" >> IPrdp.txt
    # Menampilkan IP
    echo "IP Address: $ip"
done

# Keluar setelah selesai
exit
