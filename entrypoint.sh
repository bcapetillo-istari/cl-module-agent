#!/bin/bash
set -euo pipefail

: "${REGISTRY_URL:?REGISTRY_URL must be set}"
: "${API_KEY:?API_KEY must be set}"
: "${AGENT_PAT:?AGENT_PAT must be set}"

CONFIG_FILE=/root/.config/istari_digital/istari_digital_config.yaml
mkdir -p /root/.config/istari_digital

if ! grep -q '^cli:' "$CONFIG_FILE" 2>/dev/null; then
    echo "Configuring Istari CLI..."
    stari client init "$REGISTRY_URL" "$API_KEY" -y
fi

if ! grep -q '^agent:' "$CONFIG_FILE" 2>/dev/null; then
    echo "Configuring Istari Agent..."
    stari agent init "$REGISTRY_URL" "$AGENT_PAT"
fi

# Configure agent config as per 301 tutorial
if ! grep -q 'istari_digital_agent_headless_mode' "$CONFIG_FILE"; then
    sed -i '/^agent:/a\    istari_digital_agent_headless_mode: true' "$CONFIG_FILE"
fi
if ! grep -q '^default:' "$CONFIG_FILE"; then
    echo 'default: {}' >> "$CONFIG_FILE"
fi

# Bind-mounted module executables can lose the exec bit depending on host filesystem.
find /opt/local/istari_agent/istari_modules -mindepth 2 -maxdepth 2 -type f -name cl_module -exec chmod +x {} +

echo "Starting Istari Agent ${AGENT_VERSION}..."
exec "/opt/local/istari_agent/istari_agent_${AGENT_VERSION}"
