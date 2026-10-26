#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

terraform -chdir="$ROOT/cluster" init -input=false
terraform -chdir="$ROOT/cluster" apply -auto-approve

# the platform layer is added on Day 10
if [ -d "$ROOT/platform" ]; then
  terraform -chdir="$ROOT/platform" init -input=false
  terraform -chdir="$ROOT/platform" apply -auto-approve
fi

echo "Run: export KUBECONFIG=$(terraform -chdir="$ROOT/cluster" output -raw kubeconfig_path)"