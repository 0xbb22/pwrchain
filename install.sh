#!/bin/bash

# Pindah ke direktori home
cd $HOME

# Cek dan buat direktori jika tidak ada
DIRECTORY="pwr"
if [ ! -d "$DIRECTORY" ]; then
  mkdir -p "$DIRECTORY"
fi
cd "$DIRECTORY"

# Aktifkan firewall jika belum aktif dan izinkan port tertentu
if ! sudo ufw status | grep -q "active"; then
  echo y | sudo ufw enable
fi

PORTS=("22/tcp" "80/tcp" "8231/tcp" "8085/tcp" "7621/udp")
for port in "${PORTS[@]}"; do
  if ! sudo ufw status | grep -q "$port"; then
    sudo ufw allow $port
  fi
done

# Update dan upgrade sistem
sudo apt-get update -y && sudo apt-get upgrade -y

# Instal screen jika belum terpasang
if ! command -v screen &> /dev/null; then
  sudo apt-get install -y screen
fi

# Instal Java jika belum terpasang
if ! command -v java &> /dev/null; then
  sudo apt-get install -y openjdk-19-jre-headless
fi

# Download file validator dan konfigurasi jika belum ada
VALIDATOR_JAR="validator.jar"
CONFIG_JSON="config.json"

if [ ! -f "$VALIDATOR_JAR" ]; then
  wget -q https://github.com/pwrlabs/PWR-Validator-Node/raw/main/validator.jar
fi

if [ ! -f "$CONFIG_JSON" ]; then
  wget -q https://github.com/pwrlabs/PWR-Validator-Node/raw/main/config.json
fi

# Input password
read -sp "Masukkan password yang Anda inginkan: " user_password
echo
echo "$user_password" | sudo tee password > /dev/null

# Dapatkan IP server
SERVER_IP=$(hostname -I | cut -d' ' -f1)

# Jalankan validator node di latar belakang
screen -dmS pwr
screen -S pwr -p 0 -X stuff $'sudo java -jar validator.jar password '$SERVER_IP' --compression-level 0\n'

# Pesan Informasi
echo "Validator node telah berjalan di latar belakang."
echo "Untuk memeriksa, gunakan: screen -Rd pwr"
echo "Terima kasih telah menggunakan script ini. Jangan lupa untuk bergabung dengan channel kami: https://t.me/ugdairdrop"
