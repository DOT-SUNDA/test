#!/bin/bash

# Menyimpan password yang tetap sama
password="Dotaja123@HHHH"

# Daftar email dipisahkan dengan koma
emails="$1"

# URL API dan file yang akan diupload
url="https://direct.mnl.cloudsigma.com/api/2.0/drives/upload/"
file="dotaja"

# Mengubah daftar email menjadi array
IFS=',' read -r -a email_array <<< "$emails"

# Loop melalui semua email untuk mengupload file
for email in "${email_array[@]}"; do
    # Menjalankan curl untuk mengupload file
    echo "Mengupload dengan akun $email..."
    curl --request POST --user "$email:$password" \
         --header 'Content-Type: application/octet-stream' \
         --upload-file "$file" \
         "$url"
    
    echo "Upload selesai untuk $email."
done
