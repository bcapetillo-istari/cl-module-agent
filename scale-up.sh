#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

COUNT="${1:-}"
if [ -z "$COUNT" ]; then
    COUNT=$(grep -E '^REPLICA_COUNT=' .env 2>/dev/null | cut -d= -f2)
fi
: "${COUNT:=1}"

echo "Starting $COUNT ephemeral agent replica(s)..."
docker compose up -d --build --scale "cl-agent-replica=$COUNT" cl-agent-replica
