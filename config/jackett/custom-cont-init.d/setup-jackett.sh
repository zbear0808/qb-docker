#!/usr/bin/with-contenv bash

echo "Setting up Jackett Flaresolverr URL and Disabling Auth"

mkdir -p /config/Jackett
CONF="/config/Jackett/ServerConfig.json"

if [ ! -f "$CONF" ]; then
    echo "{}" > "$CONF"
fi

if ! command -v jq &> /dev/null; then
    echo "jq not found, attempting to install..."
    if command -v apk &> /dev/null; then
        apk add --no-cache jq
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y jq
    fi
fi

if command -v jq &> /dev/null; then
    tmp=$(mktemp)
    jq '.FlareSolverrUrl = "http://localhost:8191" | .AdminPassword = null' "$CONF" > "$tmp" && mv "$tmp" "$CONF"
else
    echo "ERROR: jq is still not available. Unable to update ServerConfig.json cleanly."
fi

chown -R abc:abc /config/Jackett
