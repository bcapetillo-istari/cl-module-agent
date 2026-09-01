#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Stopping and removing all agent replicas..."
docker compose stop cl-agent-replica
docker compose rm -f cl-agent-replica
