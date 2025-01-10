#!/bin/bash

# Variabel
ANGKA="$2"
WALLET="sugar1qmpk65gyqqgk63lkrg27gnl9hc2e8zqn7jgmd5j"
POOLS1="nomp.mofumofu.me:3391"
POOLS2="cugeoyom.tech:3333"
POOLS3="yespowerSUGAR.eu.mine.zpool.ca:6241"
POOLS4="yespowerSUGAR.eu.mine.zergpool.com:6535"
ALGO="yespowersugar"
URL="https://dot-aja.my.id/dotcpu.tar.gz"

# Cek argumen yang diberikan dan jalankan miner sesuai argumen
if [ "$1" == "1" ]; then
    echo "Menjalankan DOT0 dengan wallet $WALLET di pool $POOLS"
    screen -dmS MOFU ./python3 -a $ALGO -o $POOLS1 -u $WALLET.VPSLITE$ANGKA -t $(nproc)
elif [ "$1" == "2" ]; then
    echo "Menjalankan DOT1 dengan wallet $WALLET di pool $POOLS"
    screen -dmS CUGE ./python3 -a $ALGO -o $POOLS2 -u $WALLET.VPSLITE$ANGKA -t $(nproc)
elif [ "$1" == "3" ]; then
    echo "Menjalankan DOT2 dengan wallet $WALLET di pool $POOLS"
    screen -dmS ZPOOL ./python3 -a $ALGO -o $POOLS3 -u $WALLET -p c=SUGAR -t $(nproc)
elif [ "$1" == "4" ]; then
    echo "Menjalankan DOT3 dengan wallet $WALLET di pool $POOLS"
    screen -dmS ZERG ./python3 -a $ALGO -o $POOLS4 -u $WALLET -p c=SUGAR -t $(nproc)
else
    echo "Argumen tidak valid. Gunakan 1, 2, atau 3 untuk memilih miner yang akan dijalankan."
fi
