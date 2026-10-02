#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# ── Start LocalStack ──────────────────────────────────────────────────────────

echo "Starting LocalStack..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d

echo "Waiting for LocalStack to be ready..."
until [ "$(docker inspect --format='{{.State.Health.Status}}' localstack 2>/dev/null)" = "healthy" ]; do
  sleep 2
done
echo "LocalStack is ready."

# ── Apply Terraform ───────────────────────────────────────────────────────────

echo "Initializing Terraform..."
terraform -chdir="$ROOT_DIR" init -reconfigure

echo "Applying Terraform..."
terraform -chdir="$ROOT_DIR" apply -auto-approve
