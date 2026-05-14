#!/bin/bash
set -e

echo "🚀 Installing Xray VLESS Reality (4 Core Optimized)..."

# نصب آخرین نسخه Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta

mkdir -p ~/xray ~/logs
cd ~/xray

# تولید UUID و Reality Keys (یک بار)
if [ ! -f uuid.txt ]; then
    UUID=$(xray uuid)
    echo "$UUID" > uuid.txt
    
    KEYPAIR=$(xray x25519)
    PRIVATE_KEY=$(echo "$KEYPAIR" | grep "Private key" | awk '{print $3}')
    PUBLIC_KEY=$(echo "$KEYPAIR" | grep "Public key" | awk '{print $3}')
    
    echo "$PRIVATE_KEY" > private.key
    echo "$PUBLIC_KEY" > public.key
fi

UUID=$(cat uuid.txt)
PRIVATE=$(cat private.key)
PUBLIC=$(cat public.key)

# کانفیگ بهینه برای ۴ هسته
cat > config.json << EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{ 
        "id": "$UUID", 
        "flow": "xtls-rprx-vision",
        "level": 0
      }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "xhttp",
      "security": "reality",
      "realitySettings": {
        "show": false,
        "dest": "www.microsoft.com:443",
        "xver": 0,
        "serverNames": ["www.microsoft.com", "microsoft.com"],
        "privateKey": "$PRIVATE",
        "shortIds": ["0123456789abcdef"]
      }
    }
  }],
  "outbounds": [{ "protocol": "freedom", "tag": "direct" }]
}
EOF

echo "✅ نصب با موفقیت انجام شد!"
echo "🔑 UUID: $UUID"
echo "🔑 Public Key: $PUBLIC"
echo ""
echo "📌 لاگ: screen -r xray"

# اجرای Xray
screen -dmS xray xray run -c ~/xray/config.json
