#!/bin/bash
# Automatically configure the Jackett search plugin for qBittorrent
# by reading the API key from Jackett's ServerConfig.json

JACKETT_CONF="/jackett-config/Jackett/ServerConfig.json"
QB_JACKETT_JSON="/config/qBittorrent/nova3/engines/jackett.json"
JACKETT_URL="http://localhost:9117"

echo "Configuring qBittorrent Jackett search plugin..."

# Wait for Jackett config to exist (it generates the API key on first boot)
TRIES=0
MAX_TRIES=30
while [ ! -f "$JACKETT_CONF" ] && [ "$TRIES" -lt "$MAX_TRIES" ]; do
    echo "Waiting for Jackett config to appear... ($TRIES/$MAX_TRIES)"
    sleep 2
    TRIES=$((TRIES + 1))
done

if [ ! -f "$JACKETT_CONF" ]; then
    echo "ERROR: Jackett config not found at $JACKETT_CONF after waiting. Skipping."
    exit 0
fi

# Extract the API key - try jq first, fall back to grep
if command -v jq &> /dev/null; then
    API_KEY=$(jq -r '.APIKey' "$JACKETT_CONF")
elif command -v python3 &> /dev/null; then
    API_KEY=$(python3 -c "import json; print(json.load(open('$JACKETT_CONF'))['APIKey'])")
else
    API_KEY=$(grep -o '"APIKey"[[:space:]]*:[[:space:]]*"[^"]*"' "$JACKETT_CONF" | sed 's/.*"APIKey"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
fi

if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ]; then
    echo "ERROR: Could not extract API key from Jackett config. Skipping."
    exit 0
fi

echo "Found Jackett API key: ${API_KEY:0:8}..."

# Ensure the plugin directory exists
mkdir -p "$(dirname "$QB_JACKETT_JSON")"

# Write the jackett.json config for qBittorrent's search plugin
cat > "$QB_JACKETT_JSON" << EOF
{
    "api_key": "$API_KEY",
    "thread_count": 20,
    "tracker_first": false,
    "url": "$JACKETT_URL"
}
EOF

echo "Jackett search plugin configured successfully (url=$JACKETT_URL)"
