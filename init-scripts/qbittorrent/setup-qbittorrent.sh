#!/usr/bin/with-contenv bash

echo "Setting up qBittorrent to bypass local authentication"

mkdir -p /config/qBittorrent
CONF="/config/qBittorrent/qBittorrent.conf"
touch "$CONF"

if ! grep -q "^\[Preferences\]" "$CONF"; then
    echo "[Preferences]" >> "$CONF"
fi

# Remove existing keys if they exist
sed -i '/^WebUI\\AuthSubnetWhitelistEnabled/d' "$CONF"
sed -i '/^WebUI\\AuthSubnetWhitelist=/d' "$CONF"
sed -i '/^WebUI\\LocalHostAuth=/d' "$CONF"

# Add keys to bypass authentication for local and Tailscale IPs
sed -i '/^\[Preferences\]/a WebUI\\AuthSubnetWhitelistEnabled=true\nWebUI\\AuthSubnetWhitelist=10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10\nWebUI\\LocalHostAuth=false' "$CONF"

chown -R abc:abc /config/qBittorrent
