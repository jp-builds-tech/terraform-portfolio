#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/env.sh"

docker rm -f moto >/dev/null 2>&1 || true
docker run -d --name moto -p 5000:5000 motoserver/moto:latest >/dev/null

echo "waiting for emulator..."
for _ in $(seq 1 30); do
  curl -s -o /dev/null http://localhost:5000/moto-api/ && break
  sleep 1
done

terraform -chdir="$ROOT/bootstrap" init -input=false
terraform -chdir="$ROOT/bootstrap" apply -auto-approve

terraform -chdir="$ROOT/network" init -input=false -reconfigure -backend-config=backend.hcl
terraform -chdir="$ROOT/network" apply -auto-approve

echo "In a new terminal, run: source $ROOT/scripts/env.sh"
