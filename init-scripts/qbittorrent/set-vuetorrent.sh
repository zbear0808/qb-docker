#!/bin/bash
# This script runs on container startup before qBittorrent launches to automatically configure VueTorrent

CONF_FILE="/config/qBittorrent/qBittorrent.conf"

echo "Applying VueTorrent configuration..."

# Make sure the config directory and file exist
mkdir -p /config/qBittorrent
touch "$CONF_FILE"

# Ensure the [Preferences] section exists
if ! grep -q "^\[Preferences\]" "$CONF_FILE"; then
    echo "[Preferences]" >> "$CONF_FILE"
fi

# Set AlternativeUIEnabled to true
if grep -q "^WebUI\\\\AlternativeUIEnabled=" "$CONF_FILE"; then
    sed -i 's/^WebUI\\AlternativeUIEnabled=.*/WebUI\\AlternativeUIEnabled=true/' "$CONF_FILE"
else
    sed -i '/^\[Preferences\]/a WebUI\\AlternativeUIEnabled=true' "$CONF_FILE"
fi

# Set RootFolder to /vuetorrent
if grep -q "^WebUI\\\\RootFolder=" "$CONF_FILE"; then
    sed -i 's|^WebUI\\RootFolder=.*|WebUI\\RootFolder=/vuetorrent|' "$CONF_FILE"
else
    sed -i '/^\[Preferences\]/a WebUI\\RootFolder=/vuetorrent' "$CONF_FILE"
fi

echo "VueTorrent configuration applied successfully."
