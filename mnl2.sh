#!/bin/bash
svr="mnl2"
# Password tetap
password="Dotaja123@HHHH"
emails="dotaja@khayden.com"
server_name="memek"
vnc_password="kontoljembud"

meki=$(echo $emails | awk -F',' '{print $1}' | awk -F'@' '{print $1}')
# Ubah daftar email menjadi array
IFS=',' read -r -a email_array <<< "$emails"

for email in "${email_array[@]}"; do
    # Buat token otentikasi
    auth_token=$(echo -n "$email:$password" | base64)

    # Upload file
    drive_id=$(curl -s -X POST "https://$svr.cloudsigma.com/api/2.0/libdrives/efbf37af-6dc3-4186-9dfe-a9ac14bafb91/action/?do=clone" \
                            -H "Content-Type: application/json" \
                            -H "Authorization: Basic $auth_token" \
                            -d '{}' | jq -r '.objects[0].uuid')

    # Buat server
    server_response=$(curl -s -X POST "https://$svr.cloudsigma.com/api/2.0/servers/" \
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

    server_id=$(echo "$server_response" | jq -r '.objects[0].uuid')
    
    # Jalankan server
    echo "Menjalankan server untuk ID: $server_id..."
    run_response=$(curl -s -X POST "https://$svr.cloudsigma.com/api/2.0/servers/$server_id/action/?do=start" \
                       -H "Content-Type: application/json" \
                       -H "Authorization: Basic $auth_token" \
                       -d '{}') > /dev/null 2>&1

    sleep 10
    
    # Dapatkan IP server
    ip=$(curl -s -X GET "https://$svr.cloudsigma.com/api/2.0/servers/$server_id/" \
    -H "Content-Type: application/json" \
    -H "Authorization: Basic $auth_token" | jq -r '.runtime.nics[0].ip_v4.uuid') >> ip-$meki.txt
    
done

echo "Vps Ubuntu 18 Lts Berhasil Di Buat"
echo "User : cloudsigma"
echo "Pass : Cloud2024"
echo "IP LIST :"
echo "cat ip-$meki.txt"
rm ip-$meki.txt
exit
